# 📑 Índice - Scripts de Gerenciamento Kafka OCI

Bem-vindo! Este diretório contém scripts completos para criar e gerenciar clusters Kafka na Oracle Cloud Infrastructure.

## 📦 Arquivos Criados

### 🎬 Scripts Principais

1. **`create-kafka-cluster.sh`** (8.8K) ⭐
   - Script principal para criar clusters Kafka
   - Gera automaticamente todos os arquivos JSON necessários
   - Inclui validações completas e tratamento de erros
   - Interface interativa com confirmações
   - **Use este script para criar novos clusters**

2. **`manage-kafka-clusters.sh`** (11K) ⭐
   - Script para gerenciar clusters existentes
   - Comandos: list, get, status, endpoints, update, delete
   - **Use este script para gerenciar clusters criados**

### 📖 Documentação

3. **`QUICK-START.md`** (5.7K) 🚀
   - **COMECE AQUI!** Guia rápido de 5 minutos
   - Passo a passo para criar seu primeiro cluster
   - Exemplos práticos e troubleshooting
   - **Leia isto primeiro se você é novo**

4. **`README-KAFKA-CLUSTER.md`** (6.7K) 📚
   - Documentação completa e detalhada
   - Referência de todos os parâmetros
   - Múltiplos exemplos de uso
   - Troubleshooting avançado
   - **Consulte para referência completa**

5. **`INDEX.md`** (este arquivo)
   - Visão geral de todos os arquivos
   - Fluxo de trabalho recomendado

### ⚙️ Configuração

6. **`.env.example`** (3.8K)
   - Template de configuração
   - Exemplos pré-configurados para diferentes cenários
   - **Copie para `.env` e edite com seus valores**

## 🎯 Fluxo de Trabalho Recomendado

```
┌─────────────────────────────────────┐
│  1. Leia o QUICK-START.md          │
│     └─> Entenda o processo básico   │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  2. Configure o .env                │
│     cp .env.example .env            │
│     nano .env                       │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  3. Crie o cluster                  │
│     source .env                     │
│     ./create-kafka-cluster.sh       │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  4. Gerencie o cluster              │
│     ./manage-kafka-clusters.sh      │
└─────────────────────────────────────┘
```

## 🚀 Comandos Rápidos

### Criar um cluster

```bash
# Método 1: Usando variáveis de ambiente
source .env
./create-kafka-cluster.sh

# Método 2: Inline
COMPARTMENT_ID="ocid1..." SUBNET_ID="ocid1..." ./create-kafka-cluster.sh
```

### Gerenciar clusters

```bash
# Listar todos os clusters
./manage-kafka-clusters.sh list <COMPARTMENT_ID>

# Ver detalhes de um cluster
./manage-kafka-clusters.sh get <CLUSTER_ID>

# Verificar status
./manage-kafka-clusters.sh status <CLUSTER_ID>

# Obter endpoints
./manage-kafka-clusters.sh endpoints <CLUSTER_ID>

# Ajuda completa
./manage-kafka-clusters.sh help
```

## 📋 Checklist de Pré-requisitos

Antes de começar, certifique-se de ter:

- [ ] OCI CLI instalado (`oci --version`)
- [ ] OCI CLI configurado (`oci iam region list`)
- [ ] Compartment ID em mãos
- [ ] Subnet ID em mãos (em uma VCN existente)
- [ ] Permissões IAM adequadas
- [ ] Scripts tornados executáveis (`chmod +x *.sh`)

## 🎓 Para Diferentes Níveis de Experiência

### 👶 Iniciante
1. Comece com **QUICK-START.md**
2. Use as configurações de exemplo em **.env.example**
3. Crie um cluster DEVELOPMENT primeiro
4. Explore com **manage-kafka-clusters.sh**

### 🧑 Intermediário
1. Leia **README-KAFKA-CLUSTER.md** para entender todas as opções
2. Customize as configurações no **.env**
3. Experimente diferentes tipos de cluster
4. Integre com suas aplicações

### 👨‍💼 Avançado
1. Estude os scripts **create-kafka-cluster.sh** e **manage-kafka-clusters.sh**
2. Customize conforme suas necessidades
3. Integre com pipelines CI/CD
4. Automatize deployments

## 📊 Estrutura dos Arquivos JSON Gerados

Durante a execução do `create-kafka-cluster.sh`, os seguintes arquivos são criados em `./temp_kafka_json/`:

```
temp_kafka_json/
├── access-subnets.json          # Configuração de sub-redes
├── broker-shape.json            # Configuração dos brokers
├── freeform-tags.json           # Tags de formato livre
├── defined-tags.json            # Tags definidas (opcional)
├── oci-command-TIMESTAMP.sh     # Comando executado (para auditoria)
└── cluster-output-TIMESTAMP.json # Saída completa (inclui CLUSTER_ID)
```

## 🔍 Onde Encontrar Informações Específicas

| Preciso de... | Arquivo | Seção |
|---------------|---------|-------|
| Começar rápido | QUICK-START.md | Todo |
| Configurar variáveis | .env.example | Exemplos |
| Lista completa de parâmetros | README-KAFKA-CLUSTER.md | Parâmetros Configuráveis |
| Exemplos de uso | README-KAFKA-CLUSTER.md | Exemplos de Uso |
| Troubleshooting | README-KAFKA-CLUSTER.md ou QUICK-START.md | Troubleshooting |
| Comandos de gerenciamento | Este arquivo | Comandos Rápidos |
| Detalhes técnicos | create-kafka-cluster.sh | Comentários inline |

## 🆘 Precisa de Ajuda?

### Problemas Comuns

**"Como obter o Compartment ID?"**
→ Ver seção "Como Obter Esses Valores?" no QUICK-START.md

**"Qual configuração usar?"**
→ Ver "Configurações Recomendadas por Cenário" no QUICK-START.md

**"Erro de autorização"**
→ Ver seção "Troubleshooting" no README-KAFKA-CLUSTER.md

**"Quanto vai custar?"**
→ Ver estimativas no final do QUICK-START.md

### Comandos de Ajuda

```bash
# Ajuda do script de criação
./create-kafka-cluster.sh --help

# Ajuda do script de gerenciamento
./manage-kafka-clusters.sh help

# Testar OCI CLI
oci iam region list

# Ver versão do OCI CLI
oci --version
```

## 🔗 Links Úteis

- [Documentação OCI Kafka](https://docs.oracle.com/en-us/iaas/Content/kafka/home.htm)
- [OCI CLI Reference - Kafka](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/kafka.html)
- [Instalação OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)

## 📈 Roadmap de Aprendizado

```
Semana 1: Conceitos Básicos
├─ Dia 1-2: Leia QUICK-START.md e crie seu primeiro cluster DEVELOPMENT
├─ Dia 3-4: Experimente os comandos de gerenciamento
└─ Dia 5-7: Conecte uma aplicação simples ao cluster

Semana 2: Configuração Avançada
├─ Dia 8-10: Leia README-KAFKA-CLUSTER.md completo
├─ Dia 11-12: Teste diferentes configurações
└─ Dia 13-14: Crie um cluster PRODUCTION

Semana 3: Produção
├─ Dia 15-17: Configure monitoramento
├─ Dia 18-19: Implemente backup/restore
└─ Dia 20-21: Otimize performance

Semana 4: Automação
├─ Dia 22-24: Integre com CI/CD
├─ Dia 25-27: Crie scripts customizados
└─ Dia 28-30: Documente seu processo
```

## 🎉 Resumo

Você tem agora um kit completo para trabalhar com Kafka na OCI:

- ✅ **2 scripts poderosos** (criação + gerenciamento)
- ✅ **3 guias documentados** (quick start + referência + índice)
- ✅ **1 template de configuração** (pronto para usar)
- ✅ **Validações automáticas** (evita erros comuns)
- ✅ **Interface interativa** (fácil de usar)
- ✅ **Arquivos JSON auto-gerados** (sem trabalho manual)
- ✅ **Suporte completo** (troubleshooting incluído)

**Próximo passo:** Abra o [QUICK-START.md](QUICK-START.md) e crie seu primeiro cluster em 5 minutos! 🚀

---

**Versão:** 1.0  
**Data:** 01/10/2025  
**Autor:** Scripts gerados automaticamente  
**Licença:** Use livremente conforme suas necessidades

