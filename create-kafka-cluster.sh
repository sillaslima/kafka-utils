#!/bin/bash

################################################################################
# Script para criar um cluster Kafka na Oracle Cloud Infrastructure (OCI)

# Descrição: Este script cria todos os arquivos JSON necessários e executa
#            o comando OCI CLI para criar um cluster Kafka gerenciado
#
# USO:
#   ./create-kafka-cluster.sh                    # Usa arquivo .env padrão
#   ./create-kafka-cluster.sh meu-arquivo.env    # Usa arquivo .env customizado
#   DEBUG=true ./create-kafka-cluster.sh         # Habilita debug das variáveis
#
# VARIÁVEIS DE AMBIENTE OBRIGATÓRIAS:
#   COMPARTMENT_ID - ID do compartment OCI
#   SUBNET_ID      - ID da subnet OCI
#
# VARIÁVEIS OPCIONAIS:
#   CLUSTER_NAME, KAFKA_VERSION, CLUSTER_TYPE, etc.
#   Veja seção CONFIGURAÇÕES DO CLUSTER abaixo
################################################################################

set -e  # Encerra o script em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

################################################################################
# CARREGAMENTO DE VARIÁVEIS DE AMBIENTE
################################################################################

# Função para carregar arquivo .env se existir
load_env_file() {
    local env_file="${1:-.env}"
    if [[ -f "$env_file" ]]; then
        print_info "Carregando variáveis de ambiente do arquivo: $env_file"
        # Usa source para carregar o arquivo .env no contexto atual
        # O set -a/set +a deve estar fora da função para funcionar corretamente
        source "$env_file"
        print_info "Arquivo .env carregado com sucesso!"
        return 0
    else
        print_warning "Arquivo .env não encontrado em: $env_file"
        return 1
    fi
}

# Habilita export automático de variáveis antes de carregar .env
set -a

# Verifica se foi passado um arquivo .env customizado como parâmetro
if [[ $# -gt 0 ]]; then
    ENV_FILE="$1"
    print_info "Usando arquivo de ambiente customizado: $ENV_FILE"
    load_env_file "$ENV_FILE"
else
    # Carrega o arquivo .env padrão se existir
    load_env_file
fi

# Desabilita export automático após carregar .env
set +a

################################################################################
# CONFIGURAÇÕES DO CLUSTER - DEFINA AS VARIÁVEIS NO ARQUIVO .env
################################################################################

# IDs dos recursos OCI (obrigatórios)
# COMPARTMENT_ID=ocid1.compartment.oc1..seu-compartment-id
# SUBNET_ID=ocid1.subnet.oc1..seu-subnet-id

# Configurações do Cluster
# CLUSTER_NAME=kafka-cluster-prod
# KAFKA_VERSION=3.5.1
# CLUSTER_TYPE=DEVELOPMENT
# COORDINATION_TYPE=ZOOKEEPER

# Configurações do Broker
# NODE_COUNT=1
# OCPU_COUNT=1
# STORAGE_SIZE=100

# Configuração do Cluster (obtida/criada automaticamente)
# O script verifica se existe uma configuração no compartment.
# Se não existir, cria automaticamente uma nova configuração.
# Depois obtém o CLUSTER_CONFIG_ID e CLUSTER_CONFIG_VERSION

# Tags (opcional)
FREEFORM_TAGS='{"Environment":"Development","Project":"KafkaManaged"}'
DEFINED_TAGS='{}'

# Diretório temporário para arquivos JSON
TEMP_DIR="./temp_kafka_json"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

################################################################################
# VALIDAÇÕES
################################################################################

print_info "Iniciando validações..."

# Verifica se o OCI CLI está instalado
if ! command -v oci &> /dev/null; then
    print_error "OCI CLI não está instalado. Por favor, instale primeiro."
    print_info "Visite: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
    exit 1
fi

# Verifica se o OCI CLI está configurado
if ! oci iam region list &> /dev/null; then
    print_error "OCI CLI não está configurado corretamente."
    print_info "Execute: oci setup config"
    exit 1
fi

# Valida valores obrigatórios
if [[ -z "$COMPARTMENT_ID" || ! "$COMPARTMENT_ID" =~ ^ocid1\.compartment\. ]]; then
    print_error "COMPARTMENT_ID não está definido ou é inválido"
    print_info "Defina no arquivo .env:"
    print_info "COMPARTMENT_ID=ocid1.compartment.oc1..seu-compartment-id"
    print_info "Valor atual: '${COMPARTMENT_ID:-NÃO DEFINIDO}'"
    exit 1
fi

if [[ -z "$SUBNET_ID" || ! "$SUBNET_ID" =~ ^ocid1\.subnet\. ]]; then
    print_error "SUBNET_ID não está definido ou é inválido"
    print_info "Defina no arquivo .env:"
    print_info "SUBNET_ID=ocid1.subnet.oc1..seu-subnet-id"
    print_info "Valor atual: '${SUBNET_ID:-NÃO DEFINIDO}'"
    exit 1
fi

# Valida cluster type
if [[ -z "$CLUSTER_TYPE" || ("$CLUSTER_TYPE" != "DEVELOPMENT" && "$CLUSTER_TYPE" != "PRODUCTION") ]]; then
    print_error "CLUSTER_TYPE deve ser DEVELOPMENT ou PRODUCTION"
    print_info "Defina no arquivo .env: CLUSTER_TYPE=DEVELOPMENT"
    exit 1
fi

# Valida coordination type
if [[ -z "$COORDINATION_TYPE" || ("$COORDINATION_TYPE" != "ZOOKEEPER" && "$COORDINATION_TYPE" != "KRAFT") ]]; then
    print_error "COORDINATION_TYPE deve ser ZOOKEEPER ou KRAFT"
    print_info "Defina no arquivo .env: COORDINATION_TYPE=ZOOKEEPER"
    exit 1
fi

# Valida storage size
if [[ -z "$STORAGE_SIZE" || $STORAGE_SIZE -lt 100 ]]; then
    print_error "STORAGE_SIZE deve ser no mínimo 100 GB"
    print_info "Defina no arquivo .env: STORAGE_SIZE=100"
    exit 1
fi

# Obtém ou cria automaticamente o cluster config ID e version
print_info "Verificando configuração do cluster Kafka..."

# Lista as configurações disponíveis e pega a mais recente
CLUSTER_CONFIG_INFO=$(oci kafka cluster-config list --compartment-id "$COMPARTMENT_ID" --query 'data[0]' --raw-output 2>/dev/null)

if [[ -z "$CLUSTER_CONFIG_INFO" || "$CLUSTER_CONFIG_INFO" == "null" ]]; then
    print_warning "Nenhuma configuração de cluster Kafka encontrada no compartment $COMPARTMENT_ID"
    print_info "Criando nova configuração automaticamente..."
    
    # Cria uma nova configuração usando a configuração mais recente disponível
    print_info "Gerando configuração mais recente..."
    
    # Gera o JSON da configuração mais recente
    print_info "Gerando template de configuração..."
    if ! oci kafka cluster-config create --generate-param-json-input latest-config > "$TEMP_DIR/latest-config.json" 2>/dev/null; then
        print_error "Falha ao gerar template de configuração"
        exit 1
    fi
    
    if [[ ! -f "$TEMP_DIR/latest-config.json" || ! -s "$TEMP_DIR/latest-config.json" ]]; then
        print_error "Arquivo de configuração não foi gerado corretamente"
        exit 1
    fi
    
    print_info "Executando: oci kafka cluster-config create --compartment-id $COMPARTMENT_ID --latest-config file://$TEMP_DIR/latest-config.json"
    
    if oci kafka cluster-config create --compartment-id "$COMPARTMENT_ID" --latest-config file://"$TEMP_DIR/latest-config.json" > "$TEMP_DIR/cluster-config-output-${TIMESTAMP}.json" 2>&1; then
        print_info "Configuração criada com sucesso!"
        
        # Obtém a configuração recém-criada
        CLUSTER_CONFIG_INFO=$(oci kafka cluster-config list --compartment-id "$COMPARTMENT_ID" --query 'data[0]' --raw-output 2>/dev/null)
        
        if [[ -z "$CLUSTER_CONFIG_INFO" || "$CLUSTER_CONFIG_INFO" == "null" ]]; then
            print_error "Não foi possível obter a configuração recém-criada"
            exit 1
        fi
    else
        print_error "Falha ao criar configuração do cluster Kafka"
        print_error "Verifique os logs em: $TEMP_DIR/cluster-config-output-${TIMESTAMP}.json"
        cat "$TEMP_DIR/cluster-config-output-${TIMESTAMP}.json"
        exit 1
    fi
else
    print_info "Configuração existente encontrada!"
fi

# Extrai o ID e versão da configuração
CLUSTER_CONFIG_ID=$(echo "$CLUSTER_CONFIG_INFO" | jq -r '.id' 2>/dev/null)
CLUSTER_CONFIG_VERSION=$(echo "$CLUSTER_CONFIG_INFO" | jq -r '."version"' 2>/dev/null)

if [[ -z "$CLUSTER_CONFIG_ID" || "$CLUSTER_CONFIG_ID" == "null" ]]; then
    print_error "Não foi possível obter o CLUSTER_CONFIG_ID"
    exit 1
fi

if [[ -z "$CLUSTER_CONFIG_VERSION" || "$CLUSTER_CONFIG_VERSION" == "null" ]]; then
    print_error "Não foi possível obter o CLUSTER_CONFIG_VERSION"
    exit 1
fi

print_info "Configuração do cluster Kafka:"
print_info "  CLUSTER_CONFIG_ID: $CLUSTER_CONFIG_ID"
print_info "  CLUSTER_CONFIG_VERSION: $CLUSTER_CONFIG_VERSION"

print_info "Validações concluídas com sucesso!"

################################################################################
# DEBUG DAS VARIÁVEIS DE AMBIENTE
################################################################################

# Função para mostrar variáveis de ambiente (apenas se DEBUG estiver habilitado)
show_env_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        print_info "=========================================="
        print_info "DEBUG - VARIÁVEIS DE AMBIENTE CARREGADAS"
        print_info "=========================================="
        echo "COMPARTMENT_ID: ${COMPARTMENT_ID:-'NÃO DEFINIDO'}"
        echo "SUBNET_ID: ${SUBNET_ID:-'NÃO DEFINIDO'}"
        echo "CLUSTER_NAME: ${CLUSTER_NAME:-'NÃO DEFINIDO'}"
        echo "KAFKA_VERSION: ${KAFKA_VERSION:-'NÃO DEFINIDO'}"
        echo "CLUSTER_TYPE: ${CLUSTER_TYPE:-'NÃO DEFINIDO'}"
        echo "COORDINATION_TYPE: ${COORDINATION_TYPE:-'NÃO DEFINIDO'}"
        echo "NODE_COUNT: ${NODE_COUNT:-'NÃO DEFINIDO'}"
        echo "OCPU_COUNT: ${OCPU_COUNT:-'NÃO DEFINIDO'}"
        echo "STORAGE_SIZE: ${STORAGE_SIZE:-'NÃO DEFINIDO'}"
        echo "CLUSTER_CONFIG_ID: ${CLUSTER_CONFIG_ID:-'SERÁ OBTIDO AUTOMATICAMENTE'}"
        echo "CLUSTER_CONFIG_VERSION: ${CLUSTER_CONFIG_VERSION:-'SERÁ OBTIDO AUTOMATICAMENTE'}"
        print_info "=========================================="
    fi
}

# Mostra debug se habilitado
show_env_debug

################################################################################
# CRIAÇÃO DOS ARQUIVOS JSON
################################################################################

print_info "Criando diretório temporário para arquivos JSON..."
mkdir -p "$TEMP_DIR"

# 1. Arquivo JSON para Access Subnets
print_info "Criando arquivo access-subnets.json..."
cat > "$TEMP_DIR/access-subnets.json" <<EOF
[
  {
    "subnets": ["$SUBNET_ID"]
  }
]
EOF

# 2. Arquivo JSON para Broker Shape
print_info "Criando arquivo broker-shape.json..."
cat > "$TEMP_DIR/broker-shape.json" <<EOF
{
  "nodeCount": $NODE_COUNT,
  "ocpuCount": $OCPU_COUNT,
  "storageSizeInGbs": $STORAGE_SIZE
}
EOF

# 3. Arquivo JSON para Freeform Tags
print_info "Criando arquivo freeform-tags.json..."
cat > "$TEMP_DIR/freeform-tags.json" <<EOF
$FREEFORM_TAGS
EOF

# 4. Arquivo JSON para Defined Tags (se necessário)
if [[ "$DEFINED_TAGS" != "{}" ]]; then
    print_info "Criando arquivo defined-tags.json..."
    cat > "$TEMP_DIR/defined-tags.json" <<EOF
$DEFINED_TAGS
EOF
fi

################################################################################
# RESUMO DA CONFIGURAÇÃO
################################################################################

print_info "=========================================="
print_info "RESUMO DA CONFIGURAÇÃO DO CLUSTER KAFKA"
print_info "=========================================="
echo "Nome do Cluster: $CLUSTER_NAME"
echo "Versão do Kafka: $KAFKA_VERSION"
echo "Tipo do Cluster: $CLUSTER_TYPE"
echo "Tipo de Coordenação: $COORDINATION_TYPE"
echo "Número de Nós: $NODE_COUNT"
echo "OCPUs por Nó: $OCPU_COUNT"
echo "Armazenamento (GB): $STORAGE_SIZE"
echo "Compartment ID: $COMPARTMENT_ID"
echo "Subnet ID: $SUBNET_ID"
print_info "=========================================="

# Solicita confirmação
read -p "Deseja prosseguir com a criação do cluster? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_warning "Criação do cluster cancelada pelo usuário"
    rm -rf "$TEMP_DIR"
    exit 0
fi

################################################################################
# CRIAÇÃO DO CLUSTER KAFKA
################################################################################

print_info "Iniciando criação do cluster Kafka..."

# Monta o comando base
CMD="oci kafka cluster create \
  --compartment-id '$COMPARTMENT_ID' \
  --display-name '$CLUSTER_NAME' \
  --kafka-version '$KAFKA_VERSION' \
  --cluster-type '$CLUSTER_TYPE' \
  --coordination-type '$COORDINATION_TYPE' \
  --access-subnets file://$TEMP_DIR/access-subnets.json \
  --broker-shape file://$TEMP_DIR/broker-shape.json \
  --freeform-tags file://$TEMP_DIR/freeform-tags.json"

# Adiciona cluster config se fornecido
if [[ -n "$CLUSTER_CONFIG_ID" ]]; then
    CMD="$CMD --cluster-config-id '$CLUSTER_CONFIG_ID'"
fi

if [[ -n "$CLUSTER_CONFIG_VERSION" ]]; then
    CMD="$CMD --cluster-config-version '$CLUSTER_CONFIG_VERSION'"
fi

# Adiciona defined tags se fornecido
if [[ "$DEFINED_TAGS" != "{}" ]]; then
    CMD="$CMD --defined-tags file://$TEMP_DIR/defined-tags.json"
fi

# Adiciona opção de espera e formato JSON de saída
# Para criação de cluster Kafka, aguardamos SUCCEEDED (sucesso) ou FAILED (falha)
CMD="$CMD --wait-for-state SUCCEEDED --wait-for-state FAILED --max-wait-seconds 3600"

# Salva o comando para referência
echo "$CMD" > "$TEMP_DIR/oci-command-${TIMESTAMP}.sh"
print_info "Comando salvo em: $TEMP_DIR/oci-command-${TIMESTAMP}.sh"

# Executa o comando
print_info "Executando comando OCI CLI..."
print_warning "Este processo pode levar vários minutos. Aguarde..."

# Executa e salva a saída
if eval "$CMD" > "$TEMP_DIR/cluster-output-${TIMESTAMP}.json" 2>&1; then
    print_info "=========================================="
    print_info "CLUSTER KAFKA CRIADO COM SUCESSO!"
    print_info "=========================================="
    
    # Extrai informações do cluster criado
    if command -v jq &> /dev/null; then
        CLUSTER_ID=$(jq -r '.data.id' "$TEMP_DIR/cluster-output-${TIMESTAMP}.json" 2>/dev/null || echo "N/A")
        CLUSTER_STATE=$(jq -r '.data["lifecycle-state"]' "$TEMP_DIR/cluster-output-${TIMESTAMP}.json" 2>/dev/null || echo "N/A")
        WORK_REQUEST_STATE=$(jq -r '.data["lifecycle-state"]' "$TEMP_DIR/cluster-output-${TIMESTAMP}.json" 2>/dev/null || echo "N/A")
        
        echo "Cluster ID: $CLUSTER_ID"
        echo "Estado do Cluster: $CLUSTER_STATE"
        echo "Estado da Work Request: $WORK_REQUEST_STATE"
    fi
    
    print_info "Detalhes completos salvos em: $TEMP_DIR/cluster-output-${TIMESTAMP}.json"
    print_info "=========================================="
    
    # Pergunta se deseja manter os arquivos temporários
    read -p "Deseja manter os arquivos JSON temporários? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        print_info "Limpando arquivos temporários..."
        rm -rf "$TEMP_DIR"
        print_info "Limpeza concluída!"
    else
        print_info "Arquivos mantidos em: $TEMP_DIR"
    fi
    
    exit 0
else
    print_error "=========================================="
    print_error "FALHA AO CRIAR CLUSTER KAFKA"
    print_error "=========================================="
    print_error "Verifique os logs em: $TEMP_DIR/cluster-output-${TIMESTAMP}.json"
    cat "$TEMP_DIR/cluster-output-${TIMESTAMP}.json"
    print_error "=========================================="
    print_warning "Arquivos temporários mantidos em: $TEMP_DIR para diagnóstico"
    exit 1
fi

