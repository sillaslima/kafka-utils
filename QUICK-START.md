# 🚀 Guia Rápido de Início - Cluster Kafka OCI

Este guia mostra como criar e gerenciar clusters Kafka na OCI em 5 minutos.

## ⚡ Início Rápido em 3 Passos

### 1️⃣ Configure suas credenciais OCI

```bash
# Se ainda não configurou o OCI CLI
oci setup config
```

### 2️⃣ Configure as variáveis do cluster

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite com seus valores reais
nano .env  # ou use seu editor preferido

# Carregue as variáveis
source .env
```

### 3️⃣ Crie o cluster

```bash
# Execute o script
./create-kafka-cluster.sh

# O script irá:
# ✓ Validar suas configurações
# ✓ Criar os arquivos JSON necessários
# ✓ Solicitar confirmação
# ✓ Criar o cluster
# ✓ Aguardar até ficar ativo (pode levar ~15-30 minutos)
```

## 📋 Valores Mínimos Necessários

Você precisa apenas de 2 valores para começar:

1. **COMPARTMENT_ID**: OCID do seu compartment OCI
2. **SUBNET_ID**: OCID de uma subnet existente

### Como Obter Esses Valores?

#### Via Console Web:
1. Acesse https://cloud.oracle.com
2. **Compartment ID**: Menu ☰ → Identity & Security → Compartments → Copie o OCID
3. **Subnet ID**: Menu ☰ → Networking → Virtual Cloud Networks → Selecione sua VCN → Subnets → Copie o OCID

#### Via CLI:
```bash
# Listar compartments
oci iam compartment list --all

# Listar VCNs
oci network vcn list --compartment-id <compartment-id>

# Listar subnets
oci network subnet list --compartment-id <compartment-id>
```

## 🎯 Exemplo Completo do Zero

```bash
# 1. Defina suas variáveis
export COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaaaa..."
export SUBNET_ID="ocid1.subnet.oc1..bbbbbbbb..."
export CLUSTER_NAME="meu-primeiro-kafka"
export CLUSTER_TYPE="DEVELOPMENT"

# 2. Crie o cluster
./create-kafka-cluster.sh

# 3. Aguarde a confirmação (o script aguarda automaticamente)

# 4. Verifique o status
./manage-kafka-clusters.sh status <CLUSTER_ID>

# 5. Obtenha os endpoints de conexão
./manage-kafka-clusters.sh endpoints <CLUSTER_ID>
```

## 🛠️ Gerenciamento Pós-Criação

### Listar todos os clusters

```bash
./manage-kafka-clusters.sh list $COMPARTMENT_ID
```

### Ver detalhes de um cluster

```bash
./manage-kafka-clusters.sh get <CLUSTER_ID>
```

### Verificar status

```bash
./manage-kafka-clusters.sh status <CLUSTER_ID>
```

### Obter endpoints para conectar aplicações

```bash
./manage-kafka-clusters.sh endpoints <CLUSTER_ID>
```

### Renomear um cluster

```bash
./manage-kafka-clusters.sh update <CLUSTER_ID> "novo-nome"
```

### Deletar um cluster

```bash
./manage-kafka-clusters.sh delete <CLUSTER_ID>
```

## 🔍 Testando Sua Conexão Kafka

Após criar o cluster, você pode testar a conexão:

```bash
# 1. Obtenha o endpoint bootstrap
BOOTSTRAP_ENDPOINT=$(./manage-kafka-clusters.sh endpoints <CLUSTER_ID> | grep BOOTSTRAP | cut -d: -f2- | xargs)

# 2. Teste usando kafka-console-producer (se tiver instalado)
kafka-console-producer --bootstrap-server $BOOTSTRAP_ENDPOINT --topic test-topic

# 3. Ou use um cliente Python/Java/Node.js
```

## 📊 Configurações Recomendadas por Cenário

### 🧪 Desenvolvimento/Testes
```bash
export CLUSTER_TYPE="DEVELOPMENT"
export NODE_COUNT=1
export OCPU_COUNT=1
export STORAGE_SIZE=100
```
**Custo**: Baixo | **Uso**: Dev/Test | **HA**: Não

### 🏢 Produção Padrão
```bash
export CLUSTER_TYPE="PRODUCTION"
export NODE_COUNT=3
export OCPU_COUNT=2
export STORAGE_SIZE=500
```
**Custo**: Médio | **Uso**: Produção | **HA**: Sim

### 🚀 Produção Alta Performance
```bash
export CLUSTER_TYPE="PRODUCTION"
export NODE_COUNT=5
export OCPU_COUNT=4
export STORAGE_SIZE=1000
export COORDINATION_TYPE="KRAFT"
```
**Custo**: Alto | **Uso**: Alta carga | **HA**: Sim

## ⚠️ Troubleshooting Rápido

### "Authorization failed"
→ Verifique suas permissões IAM

### "Invalid subnet"
→ Verifique se a subnet existe e está na mesma região

### "Resource limit exceeded"
→ Verifique seus limites de serviço na região

### Script não encontra OCI CLI
```bash
# Instalar OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Adicionar ao PATH
export PATH=$PATH:~/bin
```

## 📞 Precisa de Ajuda?

```bash
# Ver ajuda dos scripts
./create-kafka-cluster.sh --help
./manage-kafka-clusters.sh help

# Ver versão do OCI CLI
oci --version

# Testar conexão OCI
oci iam region list
```

## 📚 Próximos Passos

1. ✅ Cluster criado
2. 📖 Leia o [README-KAFKA-CLUSTER.md](README-KAFKA-CLUSTER.md) para detalhes completos
3. 🔐 Configure autenticação (SASL/SSL) se necessário
4. 📊 Configure monitoramento e métricas
5. 🔄 Implemente seus produtores e consumidores
6. 📈 Ajuste performance conforme necessário

## 💡 Dicas Profissionais

1. **Sempre use PRODUCTION type para cargas reais** - DEVELOPMENT não tem SLA
2. **Use NODE_COUNT ≥ 3 para alta disponibilidade** - Kafka precisa de quórum
3. **Configure tags desde o início** - Facilita gestão de custos
4. **Mantenha logs de criação** - Os arquivos em `temp_kafka_json/` são úteis
5. **Teste primeiro em DEVELOPMENT** - É mais barato para validar configurações

## 🎉 Pronto!

Agora você tem:
- ✅ Script para criar clusters (`create-kafka-cluster.sh`)
- ✅ Script para gerenciar clusters (`manage-kafka-clusters.sh`)
- ✅ Arquivo de configuração de exemplo (`.env.example`)
- ✅ Documentação completa (`README-KAFKA-CLUSTER.md`)
- ✅ Este guia rápido

**Tempo estimado de criação do cluster**: 15-30 minutos  
**Custo mensal estimado (DEVELOPMENT)**: ~$100-200 USD  
**Custo mensal estimado (PRODUCTION 3 nós)**: ~$500-800 USD

---

**Nota**: Os custos são estimativas e podem variar por região e configuração. Sempre verifique a calculadora de custos da Oracle para valores exatos.

