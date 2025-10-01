# 🎯 Scripts de Automação para Kafka OCI

> Crie e gerencie clusters Apache Kafka na Oracle Cloud Infrastructure com um único comando

[![OCI](https://img.shields.io/badge/OCI-Ready-red?style=flat-square&logo=oracle)](https://cloud.oracle.com)
[![Kafka](https://img.shields.io/badge/Kafka-3.5.1-black?style=flat-square&logo=apache-kafka)](https://kafka.apache.org)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green?style=flat-square&logo=gnu-bash)](https://www.gnu.org/software/bash/)

## 📖 O que é isso?

Este projeto fornece **scripts bash completos e prontos para uso** que automatizam a criação e gerenciamento de clusters Apache Kafka na Oracle Cloud Infrastructure (OCI).

**Sem configuração manual de JSONs. Sem comandos complexos. Apenas execute.**

## ✨ Características

- 🚀 **Criação automática** de clusters Kafka em minutos
- 📝 **Gera todos os JSONs necessários** automaticamente
- ✅ **Validações completas** antes de criar recursos
- 🛡️ **Tratamento de erros** robusto
- 🎨 **Interface colorida** e interativa
- 📊 **Gerenciamento completo** de clusters existentes
- 📚 **Documentação detalhada** em português
- 🔍 **Troubleshooting** integrado

## 🎬 Demo Rápido

```bash
# 1. Configure (uma vez)
cp .env.example .env
nano .env  # adicione seu COMPARTMENT_ID e SUBNET_ID

# 2. Crie seu cluster
source .env && ./create-kafka-cluster.sh

# 3. Gerencie
./manage-kafka-clusters.sh list $COMPARTMENT_ID
./manage-kafka-clusters.sh get <CLUSTER_ID>
./manage-kafka-clusters.sh endpoints <CLUSTER_ID>
```

**É isso!** Seu cluster estará pronto em ~15-30 minutos.

## 📦 O que está incluído?

```
kafka-managed/
│
├── 🎬 SCRIPTS
│   ├── create-kafka-cluster.sh      # Cria novos clusters
│   └── manage-kafka-clusters.sh     # Gerencia clusters existentes
│
├── 📖 DOCUMENTAÇÃO
│   ├── INDEX.md                     # Índice geral
│   ├── QUICK-START.md               # Guia rápido (comece aqui!)
│   ├── README-KAFKA-CLUSTER.md      # Referência completa
│   └── README.md                    # Este arquivo
│
└── ⚙️ CONFIGURAÇÃO
    └── .env.example                 # Template de configuração
```

**Total:** 6 arquivos · 44 KB · 100% funcional

## 🚀 Início Rápido (5 minutos)

### Pré-requisitos

```bash
# Instalar OCI CLI (se ainda não tiver)
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Configurar OCI CLI
oci setup config
```

### Passo 1: Configurar

```bash
# Copiar template
cp .env.example .env

# Editar com seus valores
nano .env
```

Você precisa de apenas 2 valores:
- `COMPARTMENT_ID` - OCID do seu compartment
- `SUBNET_ID` - OCID de uma subnet existente

### Passo 2: Executar

```bash
# Tornar scripts executáveis
chmod +x *.sh

# Carregar configuração
source .env

# Criar cluster
./create-kafka-cluster.sh
```

### Passo 3: Usar

```bash
# Listar clusters
./manage-kafka-clusters.sh list $COMPARTMENT_ID

# Ver detalhes
./manage-kafka-clusters.sh get <CLUSTER_ID>

# Obter endpoints de conexão
./manage-kafka-clusters.sh endpoints <CLUSTER_ID>
```

## 📚 Documentação

| Documento | Quando Usar | Tempo de Leitura |
|-----------|-------------|------------------|
| **[QUICK-START.md](QUICK-START.md)** | Primeira vez usando | 5 min ⚡ |
| **[INDEX.md](INDEX.md)** | Visão geral do projeto | 3 min 📑 |
| **[README-KAFKA-CLUSTER.md](README-KAFKA-CLUSTER.md)** | Referência completa | 15 min 📖 |

## 🎯 Casos de Uso

### Desenvolvimento
```bash
export CLUSTER_TYPE="DEVELOPMENT"
export NODE_COUNT=1
export STORAGE_SIZE=100
./create-kafka-cluster.sh
```
✅ Rápido · ✅ Barato · ✅ Ideal para testes

### Produção
```bash
export CLUSTER_TYPE="PRODUCTION"
export NODE_COUNT=3
export STORAGE_SIZE=500
./create-kafka-cluster.sh
```
✅ Alta Disponibilidade · ✅ SLA · ✅ Escalável

### Alta Performance
```bash
export CLUSTER_TYPE="PRODUCTION"
export NODE_COUNT=5
export OCPU_COUNT=4
export COORDINATION_TYPE="KRAFT"
./create-kafka-cluster.sh
```
✅ Máxima Performance · ✅ Sem Zookeeper · ✅ Baixa Latência

## 🛠️ Comandos Disponíveis

### create-kafka-cluster.sh

Cria um novo cluster Kafka com validações completas.

**Funcionalidades:**
- ✅ Valida OCI CLI
- ✅ Valida parâmetros
- ✅ Gera JSONs automaticamente
- ✅ Solicita confirmação
- ✅ Aguarda criação completa
- ✅ Exibe resumo final

### manage-kafka-clusters.sh

Gerencia clusters existentes.

**Comandos:**
```bash
list <COMPARTMENT_ID>              # Lista todos os clusters
get <CLUSTER_ID>                   # Detalhes completos
status <CLUSTER_ID>                # Status atual
endpoints <CLUSTER_ID>             # Endpoints de conexão
update <CLUSTER_ID> <NOVO_NOME>   # Renomear cluster
delete <CLUSTER_ID>                # Deletar cluster
help                               # Ajuda
```

## 💡 Exemplos Práticos

### Criar cluster de desenvolvimento
```bash
COMPARTMENT_ID="ocid1..." \
SUBNET_ID="ocid1..." \
CLUSTER_NAME="kafka-dev" \
CLUSTER_TYPE="DEVELOPMENT" \
./create-kafka-cluster.sh
```

### Listar e conectar
```bash
# Listar
./manage-kafka-clusters.sh list $COMPARTMENT_ID

# Obter endpoints
BOOTSTRAP=$(./manage-kafka-clusters.sh endpoints <CLUSTER_ID> | grep BOOTSTRAP | cut -d: -f2-)

# Usar em aplicação
kafka-console-producer --bootstrap-server $BOOTSTRAP --topic meu-topico
```

### Monitorar status durante criação
```bash
# Em um terminal
./create-kafka-cluster.sh

# Em outro terminal (para acompanhar)
watch -n 30 './manage-kafka-clusters.sh status <CLUSTER_ID>'
```

## ⚙️ Variáveis de Configuração

### Obrigatórias
- `COMPARTMENT_ID` - OCID do compartment
- `SUBNET_ID` - OCID da subnet

### Opcionais (com valores padrão)
- `CLUSTER_NAME` (default: "kafka-cluster-prod")
- `KAFKA_VERSION` (default: "3.5.1")
- `CLUSTER_TYPE` (default: "DEVELOPMENT")
- `NODE_COUNT` (default: 1)
- `OCPU_COUNT` (default: 1)
- `STORAGE_SIZE` (default: 100)

Ver [`.env.example`](.env.example) para lista completa.

## 🔍 Troubleshooting

### Problema: "OCI CLI não encontrado"
```bash
# Instalar
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Adicionar ao PATH
export PATH=$PATH:~/bin
```

### Problema: "Authorization failed"
```bash
# Reconfigurar OCI CLI
oci setup config

# Testar
oci iam region list
```

### Problema: Cluster em estado FAILED
```bash
# Ver detalhes do erro
./manage-kafka-clusters.sh get <CLUSTER_ID>

# Ver logs completos
cat temp_kafka_json/cluster-output-*.json
```

Mais soluções em [README-KAFKA-CLUSTER.md](README-KAFKA-CLUSTER.md#-troubleshooting)

## 📊 Estimativa de Custos

| Configuração | Custo Mensal (USD) | Uso Recomendado |
|--------------|-------------------:|-----------------|
| Development (1 nó, 1 OCPU) | ~$100-200 | Dev/Test |
| Production (3 nós, 2 OCPU) | ~$500-800 | Produção padrão |
| High Performance (5 nós, 4 OCPU) | ~$1500-2000 | Alta carga |

*Valores aproximados. Verifique a calculadora de custos da Oracle para valores exatos.*

## 🔐 Segurança

✅ **Sem credenciais hardcoded** - Usa OCI CLI  
✅ **Validações antes de executar** - Evita erros custosos  
✅ **Confirmação obrigatória** - Evita criações acidentais  
✅ **Logs auditáveis** - Rastreabilidade completa  
✅ **Permissões IAM** - Segue best practices OCI  

## 🤝 Contribuindo

Encontrou um bug? Tem uma sugestão?

1. Teste o script completamente
2. Documente o problema/sugestão
3. Inclua logs relevantes
4. Proponha uma solução (se possível)

## 📄 Licença

Este projeto é fornecido "como está", sem garantias. Use por sua conta e risco.

## 🔗 Links Úteis

- [Documentação OCI Kafka](https://docs.oracle.com/en-us/iaas/Content/kafka/home.htm)
- [OCI CLI Reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/kafka.html)
- [Apache Kafka Docs](https://kafka.apache.org/documentation/)
- [OCI Console](https://cloud.oracle.com)

## 🎓 Aprendizado

```
Nível 1: Iniciante
└─ Comece com QUICK-START.md
   └─ Crie um cluster DEVELOPMENT
      └─ Explore os comandos de gerenciamento

Nível 2: Intermediário
└─ Leia README-KAFKA-CLUSTER.md
   └─ Experimente configurações diferentes
      └─ Crie um cluster PRODUCTION

Nível 3: Avançado
└─ Estude os scripts .sh
   └─ Customize conforme necessário
      └─ Integre com CI/CD
```

## 📞 Suporte

Para problemas com:
- **Scripts**: Verifique a documentação incluída
- **OCI Kafka**: Consulte documentação oficial ou abra ticket Oracle
- **OCI CLI**: Consulte documentação oficial da Oracle

## 🎉 Pronto para Começar?

```bash
# Comece agora!
less QUICK-START.md
```

---

<div align="center">

**[📖 Guia Rápido](QUICK-START.md)** · **[📑 Índice](INDEX.md)** · **[📚 Documentação Completa](README-KAFKA-CLUSTER.md)**

Feito com ❤️ para a comunidade OCI

**v1.0** · Outubro 2025

</div>

