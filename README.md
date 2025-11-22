# 📊 Segmentação de Clientes e Análise de Risco de Crédito — Pernambuco

Projeto completo de análise de risco de crédito e segmentação de clientes Pessoa Física do estado de Pernambuco, utilizando o algoritmo **K-Prototypes** para identificar grupos com padrões distintos de comportamento financeiro.

Desenvolvido na disciplina de **Mineração de Dados** do curso de Estatística (UFS), o projeto simula um fluxo analítico adotado por áreas de risco, crédito e ciência de dados no mercado financeiro.

---

## 📚 Visão Geral

O estudo foi dividido em três etapas principais:

- **Etapa 1 — Preparação da Base:** filtragem do SCR.data (Banco Central) utilizando DuckDB + SQL.  
- **Etapa 2 — Pré-processamento:** limpeza, padronização, conversão de variáveis e construção do dataset final.  
- **Etapa 3 — Segmentação:** identificação de seis perfis de clientes com base em atributos financeiros e categóricos.

O objetivo final é fornecer uma visão clara e operacional do portfólio, destacando riscos, padrões de comportamento e oportunidades estratégicas.

---

## 🧱 Etapas do Projeto

### **1. Preparação da Base**
Filtragem da base pública **SCR.data**, mantendo somente clientes **Pessoa Física** do estado de Pernambuco, utilizando consultas SQL via DuckDB para leitura eficiente de arquivos CSV.

### **2. Pré-processamento**
A base passou por:
- remoção de variáveis redundantes,  
- padronização de campos categóricos,  
- conversão de colunas financeiras,  
- ajuste da variável número de operações,  
- padronização Z-score das variáveis numéricas.  

A versão final ficou preparada para segmentação e sem valores ausentes.

### **3. Segmentação**
Aplicação do algoritmo **K-Prototypes**, adequado para bases com variáveis numéricas e categóricas.  
Após análise dos cenários, foram definidos **seis clusters**, representando diferentes comportamentos e níveis de risco no portfólio.

---

## 📈 Resultados Principais

A segmentação identificou **seis perfis de clientes**, conforme os padrões encontrados no portfólio:

### **Perfil 1 – Cliente de Baixo Risco e Baixo Volume**
Clientes de baixa renda, operações pequenas, baixo endividamento e risco reduzido. Segmento numeroso e de baixo tíquete.

### **Perfil 2 – Super-Endividados de Alta Renda e Alto Risco**
Clientes de maior renda, porém com volumes elevados, altos valores em atraso e inadimplência expressiva. É o grupo mais crítico da carteira.

### **Perfil 3 – Clientes com Alto Uso de Crédito**
Baixa renda e uso intenso de crédito, principalmente cartão. Volume elevado, atrasos relevantes e exposição significativa ao risco.

### **Perfil 4 – Clientes de Risco Moderado com Forte Uso de Cartão**
Renda média, forte uso de cartão e risco moderado. Volume elevado e sinais de risco crescente.

### **Perfil 5 – MEIs de Alta Renda com Baixo Risco**
Microempreendedores com renda elevada, baixo volume e baixo risco. Segmento promissor para expansão de crédito.

### **Perfil 6 – Autônomos de Médio Risco e Baixa Renda**
Autônomos com renda baixa a média, risco intermediário e atrasos distribuídos entre as faixas. Segmento relevante em tamanho.

---

## 📄 Relatório Completo

📌 **Relatório oficial do projeto (PDF):**  
[Segmentação_de_Clientes_e_Análise_de_Risco_PE.pdf](report/Segmentação_de_Clientes_e_Análise_de_Risco_PE.pdf)

---

## 📁 Estrutura do Repositório

```text
segmentacao-risco-credito-pe/
│
├── data/               # Bases filtradas e tratadas
├── scripts/            # Scripts R (pré-processamento, segmentação, etc.)
├── results/            # Tabelas, gráficos e outputs
├── report/             # Relatório final em PDF
└── README.md           # Apresentação do projeto
```

## 👤 Autor

**Paulo Antônio Martins Silva**  
Graduando em **Estatística** — Universidade Federal de Sergipe (UFS)  
Interesses: **análise de dados**, **risco de crédito**, **inadimplência** e **dados de saúde**.  
