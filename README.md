# 📊 OlistLog Analytics | Executive Report

Relatório gerencial de performance logística & satisfação do cliente. Esse relatório foi criado como atividade do desafio de Power BI da Womakers Code.

## KPIs Consolidados

| Faturamento Total | Total de Pedidos | Tempo Médio de Entrega | Taxa de Atraso | Nota Média (CSAT) |
| :---: | :---: | :---: | :---: | :---: |
| **R$ 13,22 Mi** | **96,47 Mil** | **12,4 dias** | **8,11%** | **4,08** |

---

## 1. Governança, Modelagem e Qualidade dos Dados

### 1.1 Estrutura de Dados
Para garantir total consistência e performance no Power BI, os dados brutos foram estruturados e modelados no banco de dados MySQL no modelo **Star Schema** (Esquema Estrela):

* **Tabela Fato (`f_pedidos_itens`):** Construída na granularidade de item por pedido. Reúne informações financeiras (`preco_produto`, `valor_frete`, `valor_total_item`), métricas de prazos operacionais em dias (`dias_entrega_real`, `dias_atraso`) e a sinalização de atraso (`flag_pedido_atrasado`).
* **Tabela Dimensão `d_clientes`:** Atributos geográficos do comprador (`customer_id`, cidade e estado).
* **Tabela Dimensão `d_produtos`:** Categorias traduzidas para o português e características físicas dos itens.
* **Tabela Dimensão `d_vendedores`:** Identificação e localização dos parceiros comerciais (*sellers*).

### 1.2 Decisões Técnicas e Sanitização de Dados
* **Tratamento de duplicidade nas avaliações (CSAT):** Criada a tabela de *staging* `stg_avaliacoes_dedup` para agrupar as avaliações (`GROUP BY order_id`) utilizando `MAX(review_score)`. Isso impediu a multiplicação de linhas da fato na junção `LEFT JOIN`.
* **Sanitização de datas inconsistentes (`0000-00-00`):** Utilizado o tratamento `NULLIF` e a desativação do modo estrito do MySQL (`sql_mode = ''`) para converter datas zeradas em valores nulos seguros antes do cálculo dos prazos com `DATEDIFF`.
* **Escopo analítico operacional:** Apenas pedidos com status `delivered` e data de entrega preenchida foram considerados no cálculo das métricas de prazo, evitando distorções no tempo médio de entrega.

---

## 2. Análise de Negócio e Principais Achados

### 2.1 Gargalos Operacionais e Relação com a Satisfação
* **Evolução temporal:** O negócio apresenta expansão contínua no volume de faturamento e pedidos, atingindo **R$ 13,22 milhões**. No entanto, o crescimento acelerado pressionou a capacidade logística em rotas de longa distância.
* **Impacto direto na satisfação:** Os dados comprovam que atrasos na entrega impactam diretamente a avaliação do cliente. Estados com taxas de atraso elevadas registram queda expressiva na nota média de avaliação.

### 2.2 Diagnóstico Geográfico e por Categoria
* **Gargalo geográfico (Norte/Nordeste & RJ):** Alagoas lidera com **23,93%** de atrasos e Maranhão registra **19,67%**. No Sudeste, o estado do Rio de Janeiro se destaca negativamente como o maior ofensor regional, com **13,47%** de entregas fora do prazo.
* **Diagnóstico por categorias de produtos:** A categoria `seguros_e_servicos` possui a menor avaliação média (2,50), seguida por `fraldas_higiene` (3,38). Para `seguros_e_servicos`, o problema não é prazo de entrega (0% de atraso), mas sim a qualidade/expectativa do serviço comercializado.

---

## 3. Reflexão Estratégica e Plano de Ação

### 3.1 Três Oportunidades Claras para Aumentar Resultado
1. **Otimização da rota logística:** Implementar pontos de consolidação de carga (*cross-docking*) e parcerias com transportadoras regionais dedicadas ao Rio de Janeiro e capitais do Nordeste para reduzir prazos e atrasos.
2. **SLA e gestão de vendedores ofensores:** Atuar diretamente junto aos *sellers* das categorias com avaliações baixas, estabelecendo prazos limite de postagem (*pick & pack*) sob pena de perda de relevância na plataforma.
3. **Modalidade de entrega expressa no Sudeste:** Criar opções de frete rápido para a região Sudeste (aproveitando a alta concentração de vendedores em SP e PR), aumentando a taxa de conversão e atratividade no *checkout*.

### 3.2 Ineficiências e Desperdícios Identificados
* **Dependência exclusiva do frete padrão:** Altas taxas de atraso em rotas de longa distância geram acionamento excessivo do suporte ao cliente (SAC), pedidos de cancelamento e custos de estorno (*chargebacks*).
* **Demora no despacho do produto pelo vendedor:** Atrasos na separação e postagem pelo vendedor consomem a margem de tempo da transportadora, transferindo o descumprimento do prazo diretamente para o cliente final.

### 3.3 Duas Primeiras Ações Imediatas
* **Ação 1 — Notificação e SLA rígido de postagem (24h):** Exigir um prazo máximo de 24 horas úteis para postagem das mercadorias pelos vendedores localizados no Sul e Sudeste.
* **Ação 2 — Revisão de parceiros logísticos no RJ:** Abrir cotação imediata com novos operadores logísticos e transportadoras com foco de atuação na região metropolitana do RJ.  

  > *OBS:* No ranking de atrasos do dashboard, os piores estados eram do Norte e Nordeste, regiões distantes do centro de distribuição da maioria dos vendedores (SP/PR). Entretanto, o Rio de Janeiro é vizinho de São Paulo (o estado com o maior número de vendedores) e, mesmo assim, apresentou uma taxa de atraso alarmante de **13,47%**. Para a região Sudeste, uma taxa acima de 10% é considerada crítica, pois a proximidade geográfica deveria garantir prazos curtos (3 a 5 dias) e alta eficiência.

### 3.4 Informações Adicionais para Aprofundar a Análise
* **Custo unitário do frete (R$):** Para calcular a margem de contribuição real por região e produto.
* **Tempo detalhado de separação (*Pick & Pack*):** Para isolar a responsabilidade do atraso (demora do vendedor vs. atraso da transportadora).
* **Volume de chamados no SAC e cancelamentos:** Para mensurar o custo operacional direto provocado pelos atrasos nas entregas.

## Dashboard interativo
[Dashboard OlistLog Analytics](https://app.powerbi.com/view?r=eyJrIjoiM2U3OThiODMtM2VlZC00NDI0LThiOTAtOTNjNDZlNjg1NTBlIiwidCI6IjY1OWNlMmI4LTA3MTQtNDE5OC04YzM4LWRjOWI2MGFhYmI1NyJ9)

## Tecnologias usadas
![Power BI](https://img.shields.io/badge/Power_BI-F2C94C?style=for-the-badge&logo=powerbi&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-00000F?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)

```py
print('Feito com ❤️')
```
