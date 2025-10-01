#!/bin/bash

################################################################################
# Script para gerenciar clusters Kafka na Oracle Cloud Infrastructure (OCI)
# Autor: Gerado automaticamente
# Data: 01/10/2025
# Descrição: Este script permite listar, visualizar detalhes e gerenciar
#            clusters Kafka na OCI
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_title() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# Verifica se o OCI CLI está instalado
if ! command -v oci &> /dev/null; then
    print_error "OCI CLI não está instalado."
    exit 1
fi

# Verifica se jq está instalado (para formatação JSON)
if ! command -v jq &> /dev/null; then
    print_warning "jq não está instalado. A formatação de saída será limitada."
    JQ_AVAILABLE=false
else
    JQ_AVAILABLE=true
fi

################################################################################
# FUNÇÕES
################################################################################

# Função para listar todos os clusters
list_clusters() {
    local compartment_id=$1
    
    if [[ -z "$compartment_id" ]]; then
        print_error "Por favor, forneça o Compartment ID"
        echo "Uso: $0 list <COMPARTMENT_ID>"
        exit 1
    fi
    
    print_title "LISTANDO CLUSTERS KAFKA"
    print_info "Compartment: $compartment_id"
    echo ""
    
    if [[ "$JQ_AVAILABLE" == true ]]; then
        oci kafka cluster list --compartment-id "$compartment_id" | jq -r '
            .data.items[] | 
            "ID: \(.id)\n" +
            "Nome: \(.["display-name"])\n" +
            "Estado: \(.["lifecycle-state"])\n" +
            "Versão Kafka: \(.["kafka-version"])\n" +
            "Tipo: \(.["cluster-type"])\n" +
            "Criado em: \(.["time-created"])\n" +
            "----------------------------------------"
        '
    else
        oci kafka cluster list --compartment-id "$compartment_id"
    fi
}

# Função para obter detalhes de um cluster específico
get_cluster_details() {
    local cluster_id=$1
    
    if [[ -z "$cluster_id" ]]; then
        print_error "Por favor, forneça o Cluster ID"
        echo "Uso: $0 get <CLUSTER_ID>"
        exit 1
    fi
    
    print_title "DETALHES DO CLUSTER KAFKA"
    print_info "Cluster ID: $cluster_id"
    echo ""
    
    if [[ "$JQ_AVAILABLE" == true ]]; then
        local output=$(oci kafka cluster get --cluster-id "$cluster_id")
        
        echo "=== Informações Básicas ==="
        echo "$output" | jq -r '.data | 
            "Nome: \(.["display-name"])\n" +
            "Estado: \(.["lifecycle-state"])\n" +
            "Versão Kafka: \(.["kafka-version"])\n" +
            "Tipo de Cluster: \(.["cluster-type"])\n" +
            "Tipo de Coordenação: \(.["coordination-type"])\n" +
            "Região: \(.["region"])\n" +
            "Criado em: \(.["time-created"])\n" +
            "Atualizado em: \(.["time-updated"])"
        '
        
        echo ""
        echo "=== Configuração dos Brokers ==="
        echo "$output" | jq -r '.data["broker-shape"] |
            "Número de Nós: \(.["node-count"])\n" +
            "OCPUs por Nó: \(.["ocpu-count"])\n" +
            "Armazenamento (GB): \(.["storage-size-in-gbs"])"
        '
        
        echo ""
        echo "=== Endpoints ==="
        echo "$output" | jq -r '.data.endpoints | to_entries[] |
            "\(.key | ascii_upcase): \(.value)"
        '
        
        echo ""
        echo "=== Tags ==="
        echo "$output" | jq -r '.data["freeform-tags"] // "Nenhuma tag freeform"'
        
    else
        oci kafka cluster get --cluster-id "$cluster_id"
    fi
}

# Função para deletar um cluster
delete_cluster() {
    local cluster_id=$1
    
    if [[ -z "$cluster_id" ]]; then
        print_error "Por favor, forneça o Cluster ID"
        echo "Uso: $0 delete <CLUSTER_ID>"
        exit 1
    fi
    
    print_warning "=========================================="
    print_warning "ATENÇÃO: DELEÇÃO DE CLUSTER"
    print_warning "=========================================="
    print_warning "Você está prestes a deletar o cluster:"
    print_warning "ID: $cluster_id"
    print_warning ""
    print_warning "Esta ação é IRREVERSÍVEL!"
    print_warning "Todos os dados serão perdidos permanentemente."
    print_warning "=========================================="
    
    read -p "Digite 'DELETE' (maiúsculas) para confirmar: " confirmation
    
    if [[ "$confirmation" != "DELETE" ]]; then
        print_info "Deleção cancelada."
        exit 0
    fi
    
    print_info "Deletando cluster..."
    oci kafka cluster delete --cluster-id "$cluster_id" --wait-for-state DELETED --max-wait-seconds 1800
    
    print_info "Cluster deletado com sucesso!"
}

# Função para obter endpoints do cluster
get_endpoints() {
    local cluster_id=$1
    
    if [[ -z "$cluster_id" ]]; then
        print_error "Por favor, forneça o Cluster ID"
        echo "Uso: $0 endpoints <CLUSTER_ID>"
        exit 1
    fi
    
    print_title "ENDPOINTS DO CLUSTER"
    print_info "Cluster ID: $cluster_id"
    echo ""
    
    if [[ "$JQ_AVAILABLE" == true ]]; then
        oci kafka cluster get --cluster-id "$cluster_id" | jq -r '
            .data.endpoints | to_entries[] |
            "\(.key | ascii_upcase):\n  \(.value)\n"
        '
    else
        oci kafka cluster get --cluster-id "$cluster_id" --query "data.endpoints"
    fi
}

# Função para atualizar um cluster
update_cluster() {
    local cluster_id=$1
    local new_display_name=$2
    
    if [[ -z "$cluster_id" ]]; then
        print_error "Por favor, forneça o Cluster ID e o novo nome"
        echo "Uso: $0 update <CLUSTER_ID> <NOVO_NOME>"
        exit 1
    fi
    
    if [[ -z "$new_display_name" ]]; then
        print_error "Por favor, forneça o novo nome para o cluster"
        echo "Uso: $0 update <CLUSTER_ID> <NOVO_NOME>"
        exit 1
    fi
    
    print_info "Atualizando nome do cluster..."
    oci kafka cluster update --cluster-id "$cluster_id" --display-name "$new_display_name"
    
    print_info "Cluster atualizado com sucesso!"
}

# Função para verificar status do cluster
check_status() {
    local cluster_id=$1
    
    if [[ -z "$cluster_id" ]]; then
        print_error "Por favor, forneça o Cluster ID"
        echo "Uso: $0 status <CLUSTER_ID>"
        exit 1
    fi
    
    print_info "Verificando status do cluster..."
    
    if [[ "$JQ_AVAILABLE" == true ]]; then
        local state=$(oci kafka cluster get --cluster-id "$cluster_id" | jq -r '.data["lifecycle-state"]')
        local name=$(oci kafka cluster get --cluster-id "$cluster_id" | jq -r '.data["display-name"]')
        
        echo ""
        echo "Cluster: $name"
        echo "Estado: $state"
        echo ""
        
        case "$state" in
            "ACTIVE")
                print_info "✓ Cluster está ATIVO e pronto para uso"
                ;;
            "CREATING")
                print_warning "⏳ Cluster está sendo CRIADO..."
                ;;
            "UPDATING")
                print_warning "⏳ Cluster está sendo ATUALIZADO..."
                ;;
            "DELETING")
                print_warning "⏳ Cluster está sendo DELETADO..."
                ;;
            "FAILED")
                print_error "✗ Cluster está em estado de FALHA"
                ;;
            "DELETED")
                print_info "Cluster foi DELETADO"
                ;;
            *)
                print_warning "Estado desconhecido: $state"
                ;;
        esac
    else
        oci kafka cluster get --cluster-id "$cluster_id" --query "data.\"lifecycle-state\""
    fi
}

# Função para mostrar ajuda
show_help() {
    echo ""
    echo "Script de Gerenciamento de Clusters Kafka OCI"
    echo ""
    echo "Uso: $0 <comando> [argumentos]"
    echo ""
    echo "Comandos disponíveis:"
    echo ""
    echo "  list <COMPARTMENT_ID>              Lista todos os clusters em um compartment"
    echo "  get <CLUSTER_ID>                   Mostra detalhes de um cluster específico"
    echo "  status <CLUSTER_ID>                Verifica o status de um cluster"
    echo "  endpoints <CLUSTER_ID>             Mostra os endpoints de conexão do cluster"
    echo "  update <CLUSTER_ID> <NOVO_NOME>   Atualiza o nome de um cluster"
    echo "  delete <CLUSTER_ID>                Deleta um cluster (CUIDADO!)"
    echo "  help                               Mostra esta mensagem de ajuda"
    echo ""
    echo "Exemplos:"
    echo ""
    echo "  # Listar clusters"
    echo "  $0 list ocid1.compartment.oc1..aaaaaa"
    echo ""
    echo "  # Ver detalhes de um cluster"
    echo "  $0 get ocid1.kafkacluster.oc1..bbbbbb"
    echo ""
    echo "  # Verificar status"
    echo "  $0 status ocid1.kafkacluster.oc1..bbbbbb"
    echo ""
    echo "  # Obter endpoints"
    echo "  $0 endpoints ocid1.kafkacluster.oc1..bbbbbb"
    echo ""
    echo "  # Atualizar nome"
    echo "  $0 update ocid1.kafkacluster.oc1..bbbbbb novo-nome-cluster"
    echo ""
    echo "  # Deletar cluster"
    echo "  $0 delete ocid1.kafkacluster.oc1..bbbbbb"
    echo ""
}

################################################################################
# MAIN
################################################################################

# Verifica se foi passado algum comando
if [[ $# -eq 0 ]]; then
    print_error "Nenhum comando especificado"
    show_help
    exit 1
fi

# Processa o comando
COMMAND=$1
shift

case "$COMMAND" in
    list)
        list_clusters "$@"
        ;;
    get)
        get_cluster_details "$@"
        ;;
    delete)
        delete_cluster "$@"
        ;;
    endpoints)
        get_endpoints "$@"
        ;;
    update)
        update_cluster "$@"
        ;;
    status)
        check_status "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Comando desconhecido: $COMMAND"
        show_help
        exit 1
        ;;
esac

exit 0

