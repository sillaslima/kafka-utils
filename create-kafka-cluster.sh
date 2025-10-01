#!/bin/bash

################################################################################
# Script para criar um cluster Kafka na Oracle Cloud Infrastructure (OCI)
# Autor: Gerado automaticamente
# Data: 01/10/2025
# Descrição: Este script cria todos os arquivos JSON necessários e executa
#            o comando OCI CLI para criar um cluster Kafka gerenciado
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
# CONFIGURAÇÕES DO CLUSTER - MODIFIQUE AQUI COM SEUS VALORES
################################################################################

# IDs dos recursos OCI (obrigatórios)
COMPARTMENT_ID="${COMPARTMENT_ID:-ocid1.compartment.oc1..exampleuniqueID}"
SUBNET_ID="${SUBNET_ID:-ocid1.subnet.oc1..exampleuniqueID}"

# Configurações do Cluster
CLUSTER_NAME="${CLUSTER_NAME:-kafka-cluster-prod}"
KAFKA_VERSION="${KAFKA_VERSION:-3.5.1}"  # Versões disponíveis: 2.8.0, 3.2.0, 3.5.1, etc.
CLUSTER_TYPE="${CLUSTER_TYPE:-DEVELOPMENT}"  # DEVELOPMENT ou PRODUCTION
COORDINATION_TYPE="${COORDINATION_TYPE:-ZOOKEEPER}"  # ZOOKEEPER ou KRAFT

# Configurações do Broker
NODE_COUNT="${NODE_COUNT:-1}"  # Número de nós broker
OCPU_COUNT="${OCPU_COUNT:-1}"  # Número de OCPUs por nó
STORAGE_SIZE="${STORAGE_SIZE:-100}"  # Tamanho do armazenamento em GB (mínimo 100)

# Configuração do Cluster (opcional)
CLUSTER_CONFIG_ID="${CLUSTER_CONFIG_ID:-}"
CLUSTER_CONFIG_VERSION="${CLUSTER_CONFIG_VERSION:-}"

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
if [[ "$COMPARTMENT_ID" == "ocid1.compartment.oc1..exampleuniqueID" ]]; then
    print_error "Por favor, configure COMPARTMENT_ID com um valor válido"
    exit 1
fi

if [[ "$SUBNET_ID" == "ocid1.subnet.oc1..exampleuniqueID" ]]; then
    print_error "Por favor, configure SUBNET_ID com um valor válido"
    exit 1
fi

# Valida cluster type
if [[ "$CLUSTER_TYPE" != "DEVELOPMENT" && "$CLUSTER_TYPE" != "PRODUCTION" ]]; then
    print_error "CLUSTER_TYPE deve ser DEVELOPMENT ou PRODUCTION"
    exit 1
fi

# Valida coordination type
if [[ "$COORDINATION_TYPE" != "ZOOKEEPER" && "$COORDINATION_TYPE" != "KRAFT" ]]; then
    print_error "COORDINATION_TYPE deve ser ZOOKEEPER ou KRAFT"
    exit 1
fi

# Valida storage size
if [[ $STORAGE_SIZE -lt 100 ]]; then
    print_error "STORAGE_SIZE deve ser no mínimo 100 GB"
    exit 1
fi

print_info "Validações concluídas com sucesso!"

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
CMD="$CMD --wait-for-state ACTIVE --wait-for-state FAILED --max-wait-seconds 3600"

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
        
        echo "Cluster ID: $CLUSTER_ID"
        echo "Estado: $CLUSTER_STATE"
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

