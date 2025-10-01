# Script de Criação de Cluster Kafka OCI

Este script automatiza a criação de um cluster Kafka gerenciado na Oracle Cloud Infrastructure (OCI).

## 📋 Pré-requisitos

1. **OCI CLI instalado**: 
   ```bash
   # Instalação
   bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
   ```

2. **OCI CLI configurado**:
   ```bash
   oci setup config
   ```

3. **Permissões IAM necessárias**:
   - Permissão para criar clusters Kafka
   - Acesso ao compartment e subnet especificados

4. **Recursos OCI existentes**:
   - Compartment ID (OCID)
   - Subnet ID (OCID) em uma VCN configurada

## 🚀 Como Usar

### Método 1: Configurar variáveis de ambiente

```bash
# Defina as variáveis de ambiente
export COMPARTMENT_ID="ocid1.compartment.oc1..seu_compartment_id"
export SUBNET_ID="ocid1.subnet.oc1..seu_subnet_id"
export CLUSTER_NAME="meu-cluster-kafka"
export KAFKA_VERSION="3.5.1"
export CLUSTER_TYPE="DEVELOPMENT"
export NODE_COUNT=1
export OCPU_COUNT=1
export STORAGE_SIZE=100

# Torne o script executável
chmod +x create-kafka-cluster.sh

# Execute o script
./create-kafka-cluster.sh
```

### Método 2: Editar diretamente no script

1. Abra o arquivo `create-kafka-cluster.sh`
2. Localize a seção "CONFIGURAÇÕES DO CLUSTER"
3. Modifique os valores conforme necessário:

```bash
COMPARTMENT_ID="ocid1.compartment.oc1..seu_compartment_id"
SUBNET_ID="ocid1.subnet.oc1..seu_subnet_id"
CLUSTER_NAME="meu-cluster-kafka"
# ... outras configurações
```

4. Salve e execute:
```bash
chmod +x create-kafka-cluster.sh
./create-kafka-cluster.sh
```

### Método 3: Passar variáveis inline

```bash
COMPARTMENT_ID="ocid1..." SUBNET_ID="ocid1..." ./create-kafka-cluster.sh
```

## ⚙️ Parâmetros Configuráveis

### Obrigatórios

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `COMPARTMENT_ID` | OCID do compartment | `ocid1.compartment.oc1..aaaaaa...` |
| `SUBNET_ID` | OCID da subnet | `ocid1.subnet.oc1..bbbbbb...` |

### Opcionais

| Variável | Descrição | Padrão | Valores Possíveis |
|----------|-----------|--------|-------------------|
| `CLUSTER_NAME` | Nome do cluster | `kafka-cluster-prod` | Qualquer string válida |
| `KAFKA_VERSION` | Versão do Kafka | `3.5.1` | `2.8.0`, `3.2.0`, `3.5.1`, etc. |
| `CLUSTER_TYPE` | Tipo do cluster | `DEVELOPMENT` | `DEVELOPMENT`, `PRODUCTION` |
| `COORDINATION_TYPE` | Tipo de coordenação | `ZOOKEEPER` | `ZOOKEEPER`, `KRAFT` |
| `NODE_COUNT` | Número de nós broker | `1` | Inteiro ≥ 1 |
| `OCPU_COUNT` | OCPUs por nó | `1` | Inteiro ≥ 1 |
| `STORAGE_SIZE` | Armazenamento em GB | `100` | Inteiro ≥ 100 |
| `CLUSTER_CONFIG_ID` | OCID da configuração | - | OCID (opcional) |
| `CLUSTER_CONFIG_VERSION` | Versão da configuração | - | String (opcional) |

## 📁 Arquivos JSON Gerados

O script cria automaticamente os seguintes arquivos JSON no diretório `./temp_kafka_json/`:

1. **access-subnets.json**: Configuração de sub-redes
2. **broker-shape.json**: Configuração dos brokers
3. **freeform-tags.json**: Tags de formato livre
4. **defined-tags.json**: Tags definidas (se configurado)
5. **oci-command-TIMESTAMP.sh**: Comando OCI CLI executado
6. **cluster-output-TIMESTAMP.json**: Saída completa da criação

## 🎯 Exemplos de Uso

### Exemplo 1: Cluster de Desenvolvimento Simples

```bash
export COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaa"
export SUBNET_ID="ocid1.subnet.oc1..bbbbbb"
export CLUSTER_NAME="kafka-dev"
export CLUSTER_TYPE="DEVELOPMENT"
export NODE_COUNT=1
export OCPU_COUNT=1
export STORAGE_SIZE=100

./create-kafka-cluster.sh
```

### Exemplo 2: Cluster de Produção com Alta Disponibilidade

```bash
export COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaa"
export SUBNET_ID="ocid1.subnet.oc1..bbbbbb"
export CLUSTER_NAME="kafka-prod"
export CLUSTER_TYPE="PRODUCTION"
export KAFKA_VERSION="3.5.1"
export NODE_COUNT=3
export OCPU_COUNT=2
export STORAGE_SIZE=500
export COORDINATION_TYPE="KRAFT"

./create-kafka-cluster.sh
```

### Exemplo 3: Cluster com Configuração Customizada

```bash
export COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaa"
export SUBNET_ID="ocid1.subnet.oc1..bbbbbb"
export CLUSTER_CONFIG_ID="ocid1.kafkaclusterconfig.oc1..cccccc"
export CLUSTER_CONFIG_VERSION="1.0.0"
export CLUSTER_NAME="kafka-custom"

./create-kafka-cluster.sh
```

## 🔍 Verificando o Cluster Criado

Após a criação, você pode verificar o status do cluster:

```bash
# Listar todos os clusters
oci kafka cluster list --compartment-id <compartment-id>

# Obter detalhes de um cluster específico
oci kafka cluster get --cluster-id <cluster-id>

# Verificar o endpoint do cluster
oci kafka cluster get --cluster-id <cluster-id> | jq '.data.endpoints'
```

## 🛠️ Troubleshooting

### Erro: "OCI CLI não está instalado"
**Solução**: Instale o OCI CLI seguindo a documentação oficial.

### Erro: "OCI CLI não está configurado"
**Solução**: Execute `oci setup config` para configurar suas credenciais.

### Erro: "STORAGE_SIZE deve ser no mínimo 100 GB"
**Solução**: Ajuste o valor de `STORAGE_SIZE` para 100 ou mais.

### Erro: "Authorization failed or requested resource not found"
**Solução**: Verifique se:
- Os OCIDs estão corretos
- Você tem permissões IAM adequadas
- Os recursos (compartment, subnet) existem

### Erro: "Invalid parameter value"
**Solução**: Verifique se a versão do Kafka especificada está disponível na sua região.

## 📊 Tipos de Cluster

### DEVELOPMENT
- Ideal para desenvolvimento e testes
- Menor custo
- Sem SLA de alta disponibilidade
- Configuração mínima de recursos

### PRODUCTION
- Recomendado para ambientes de produção
- Alta disponibilidade
- SLA garantido
- Requer configuração de recursos adequada

## 🔐 Segurança

O script:
- ✅ Não armazena credenciais
- ✅ Usa o OCI CLI para autenticação
- ✅ Valida entradas antes da execução
- ✅ Solicita confirmação antes de criar recursos
- ✅ Gera logs para auditoria

## 📝 Logs e Outputs

Todos os arquivos temporários são salvos em `./temp_kafka_json/` com timestamp:
- Comando executado: `oci-command-YYYYMMDD_HHMMSS.sh`
- Saída do cluster: `cluster-output-YYYYMMDD_HHMMSS.json`

## 🔗 Referências

- [Documentação OCI Kafka](https://docs.oracle.com/en-us/iaas/Content/kafka/home.htm)
- [OCI CLI Reference - Kafka Cluster Create](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/kafka/cluster/create.html)
- [Instalação OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

## 📄 Licença

Este script é fornecido como está, sem garantias.

## 👤 Suporte

Para problemas com o OCI Kafka, consulte a documentação oficial da Oracle ou abra um ticket de suporte.

