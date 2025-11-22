# Pacotes

library(tidyverse)
library(tidymodels) # Para pré-processamento (recipe)
library(readxl)     # Para ler o .xlsx do IBGE
library(skimr)      # Para diagnósticos (skim)


# Carregando os dados
setwd("~/UFS 2025.2/mineracao_dados/Análise de Risco/Projeto 2 - Pré processamento")
bacen_sujo <- read_csv("analise_pe.csv")


glimpse(bacen_sujo)
summary(bacen_sujo)
#A base de dados possue 5086 operações de crédito agregadas(linhas) e 23 colunas. 
#Algumas variaveis podem serem removidas porque possuem apenas informação repetida. São elas: "data_base", "uf", e "cliente".
#Também seram removidas as variáveis "cnae_secao" e "cnae_subclasse" porque referem-se a PJ.


bacen_limpo <- bacen_sujo %>% 
  select(-data_base, -uf, -cliente, -cnae_secao, -cnae_subclasse, -tcb, -sr, -origem, -indexador )


#Vamos retirar o "PF -" das variaveis Porte, ocupação e modalidade. 

bacen_limpo <- bacen_limpo %>% 
  mutate(porte = str_remove(porte, "^PF - "),
         ocupacao = str_remove(ocupacao, "^PF - "),
         modalidade = str_remove(modalidade, "^PF - "))

#Tratando a variável "numero_de_operacoes". Substituir a entrada "<=15" pelo ponto médio.


bacen_limpo <- bacen_limpo %>%
  mutate(
    numero_de_operacoes = ifelse(
      numero_de_operacoes == "<= 15",
      round((0 + 15) / 2, 0),  
      numero_de_operacoes
    ),
    numero_de_operacoes = as.numeric(numero_de_operacoes)
  )


#Convertendo variáveis para numerica e susbtituindo a virgula pelo ponto.

bacen_limpo <- bacen_limpo %>%
  mutate(
    vencido_acima_de_15_dias = as.numeric(gsub(",", ".", vencido_acima_de_15_dias)),
    carteira_ativa = as.numeric(gsub(",", ".", carteira_ativa)),
    carteira_inadimplida_arrastada = as.numeric(gsub(",", ".", carteira_inadimplida_arrastada)),
    ativo_problematico = as.numeric(gsub(",", ".", ativo_problematico)),
    across(starts_with("a_"), ~ as.numeric(gsub(",", ".", .x)))
  )

#Verificar inconsistencias para as variaveis categoricas. 
lapply(bacen_limpo[c("ocupacao", "porte", "modalidade")], table)

summary(bacen_limpo)
colSums(is.na(bacen_limpo))


#write.csv(bacen_limpo, "bacen_limpo.csv", row.names = FALSE)


# Padronização (Z-Score) via `recipes`

# 1. Definir a Receita
receita_padronizacao <- recipe(~., bacen_limpo) |>
  
  # Converte todas as colunas de texto (nominais) para 'factor'
  step_string2factor(all_nominal_predictors()) |>
  
  # Aplica a padronização Z-score (média 0, var 1)
  step_normalize(all_numeric_predictors())

# 2. Preparar a Receita
# 'prep()' calcula a média e o SD dos dados de treinamento
receita_preparada <- prep(receita_padronizacao, training = bacen_limpo)

# 3. Aplicar a Receita
# 'bake()' aplica os parâmetros calculados no 'prep()'
dados_padronizados_final <- bake(receita_preparada, new_data = bacen_limpo)

# 4. Verificar o Resultado
glimpse(dados_padronizados_final)

# Verificando se as variaveis númericas foram padronizadas. 
dados_padronizados_final |>
  skim()


#write.csv(dados_padronizados_final, "bacen_padronizado.csv", row.names = FALSE)



######Agrupamento

# K-Prototype - Encontrando k ótimo


# Rodando o Método do Cotovelo (WCSS Híbrida)
k_values <- 2:10
wcss_kproto <- map_dbl(k_values, ~ {
  
  # 'nstart = 5' roda 5x e pega o melhor resultado para evitar 
  # um "ótimo local" ruim.
  model <- kproto(
    x = dados_padronizados_final, 
    k = .x, 
    nstart = 8, 
    iter.max = 10,
    verbose = FALSE # Desliga as mensagens de progresso
  )
  
  model$tot.withinss # Soma dos quadrados intra-clusters (WCSS) Híbrida
})


# Gráfico do Cotovelo
data.frame(k = k_values, wcss = wcss_kproto) |>
  ggplot(aes(x = k, y = wcss)) +
  geom_line(size = 1) + 
  geom_point(size = 3) +
  geom_vline(xintercept = 6, linetype = "dashed") + # Exemplo: se k=4 for o cotovelo
  labs(title = "Método do Cotovelo para K-Prototypes",
       x = "Número de Clusters (k)",
       y = "WCSS Híbrida Total")

# usaremos o 6

# K-Prototype - Aplicação do Método

# Modelagem
set.seed(123)
modelo_kp <- kproto(
  x = dados_padronizados_final, 
  k = 6, 
  nstart = 10
)


# Para facilitar a interpretação dos clusters, vamos ver os dados originais
dados_cluster_final <- bacen_limpo |>
  mutate(Cluster = modelo_kp$cluster)



# Ver as médias das variáveis numéricas originais
dados_cluster_final |>
  group_by(Cluster) |>
  summarise(
    Media_Operacoes = mean(numero_de_operacoes, na.rm = TRUE),
    Media_Ate90 = mean(a_vencer_ate_90_dias, na.rm = TRUE),
    Media_91a360 = mean(a_vencer_de_91_ate_360_dias, na.rm = TRUE),
    Media_361a1080 = mean(a_vencer_de_361_ate_1080_dias, na.rm = TRUE),
    Media_1081a1800 = mean(a_vencer_de_1081_ate_1800_dias, na.rm = TRUE),
    Media_1801a5400 = mean(a_vencer_de_1801_ate_5400_dias, na.rm = TRUE),
    Media_Acima5400 = mean(a_vencer_acima_de_5400_dias, na.rm = TRUE),
    Media_Vencido15 = mean(vencido_acima_de_15_dias, na.rm = TRUE),
    Media_Ativa = mean(carteira_ativa, na.rm = TRUE),
    Media_Inadimplida = mean(carteira_inadimplida_arrastada, na.rm = TRUE),
    Media_AtivoProb = mean(ativo_problematico, na.rm = TRUE),
    Contagem = n()
  ) %>% 
print(n = Inf, width = Inf)


# Ver as modas (categorias mais comuns) das variáveis categóricas

table(dados_cluster_final$ocupacao)
dados_cluster_final |>
  group_by(Cluster, ocupacao) |>
  summarise(Contagem = n()) |>
  slice_max(order_by = Contagem, n = 1)

dados_cluster_final |>
  group_by(Cluster, porte) |>
  summarise(Contagem = n()) |>
  slice_max(order_by = Contagem, n = 1)

dados_cluster_final |>
  group_by(Cluster, modalidade) |>
  summarise(Contagem = n()) |>
  slice_max(order_by = Contagem, n = 1)





