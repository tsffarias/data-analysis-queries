/* 
** QUERIES DEPARTAMENTO MARKETING **
*/

/* Custo por Clique (CPC) de Campanhas */
/* Calcula o custo médio que a empresa paga por cada clique em uma determinada campanha de marketing. */
SELECT (Valor_Gasto_em_Marketing / Cliques) AS CPC
FROM campanhas_table
WHERE campanha = 'Nome_da_Campanha';

/* Custo de Aquisição do Cliente (CAC) */
/* Calcula o custo médio para adquirir um novo cliente através de uma campanha de marketing. */
SELECT (Valor_Gasto_em_Marketing / Novos_Clientes_Adquiridos) AS CAC
FROM campanhas_table
WHERE campanha = 'Nome_da_Campanha';

/* Retorno sobre o investimento em marketing (ROI) */
/* Calcula o retorno financeiro gerado por uma campanha de marketing em relação ao investimento feito. */
SELECT ((Receita_Gerada - Valor_Gasto_em_Marketing) / Valor_Gasto_em_Marketing) AS ROI
FROM campanhas_table
WHERE campanha = 'Nome_da_Campanha';

/* Taxa de Cliques (CTR) */
/* Mede a proporção de cliques em relação ao número de impressões de anúncios. */
SELECT (Cliques / Impressões) AS CTR
FROM campanhas_table
WHERE campanha = 'Nome_da_Campanha';

/* Conversão */
/* Calcula a taxa de conversão de cliques em pedidos. */
SELECT (Pedidos / Cliques) AS Conversão
FROM campanhas_table
WHERE campanha = 'Nome_da_Campanha';

/* Taxa de Conversão de Cliques em Pedidos (CCR) */
/* Métrica para medir a eficácia das campanhas de marketing em gerar pedidos. */
SELECT (COUNT(DISTINCT pedidos) / COUNT(DISTINCT cliques)) AS CCR
FROM cliques_table
WHERE campanha = 'Nome_da_Campanha';

/* Taxa de Retenção de Clientes */
/* Indica a porcentagem de clientes que retornam para fazer pedidos novamente. */
SELECT (COUNT(DISTINCT clientes_retornados) / COUNT(DISTINCT todos_os_clientes)) AS Retenção_Clientes
FROM pedidos_table
WHERE data BETWEEN '2024-01-01' AND '2024-03-31';

/* Custo por Aquisição (CPA)*/
/* Quanto custa para adquirir um novo cliente através de uma campanha de marketing. */
SELECT (Valor_Gasto_em_Marketing / Novos_Clientes_Adquiridos) AS CPA
FROM campanhas_table
WHERE data = '2024-03-01';

/* Lifetime Value (LTV) do Cliente */
/* Valor total esperado que um cliente gasta durante seu relacionamento com a marca. */
SELECT AVG(valor_total_pedidos) AS LTV
FROM pedidos_table
WHERE data BETWEEN '2023-01-01' AND '2024-01-01';

/* Taxa de Engajamento nas Redes Sociais */
/* Mede a interação dos usuários com o conteúdo da empresa nas redes sociais. */
SELECT (Interações / Seguidores) AS Engajamento
FROM redes_sociais
WHERE plataforma = 'Instagram'
AND data_postagem BETWEEN '2024-01-01' AND '2024-03-31';

/* Vendas totais por campanha (GMV) */
/* Calcula o valor total das vendas gerado por uma campanha de marketing. */
SELECT campanha, SUM(valor_total_pedidos) AS GMV
FROM pedidos_table
WHERE campanha = 'Nome_da_Campanha'
GROUP BY campanha;

/* Número de pedidos */
/* Conta o número total de pedidos realizados. */
SELECT campanha, COUNT(DISTINCT order_id) AS Num_Pedidos
FROM pedidos_table
WHERE campanha = 'Nome_da_Campanha'
GROUP BY campanha;

/* Número de Clientes por Campanha */
/* Conta o número de clientes distintos que fizeram pedidos durante uma campanha. */
SELECT COUNT(DISTINCT cliente_id) AS Num_Clientes
FROM pedidos_table
WHERE campanha = 'Nome_da_Campanha';

/* Vendas por segmentação de parte do dia */
/* Calcula as vendas por segmento de horário do dia (Manhã, Meio-dia, Anoitecer/Final da Tarde, Noite, De manhã cedo).*/
SELECT 
    CASE 
        WHEN hora > 4 AND hora <= 8 THEN 'Early Morning'
        WHEN hora > 8 AND hora <= 12 THEN 'Morning'
        WHEN hora > 12 AND hora <= 16 THEN 'Afternoon'
        WHEN hora > 16 AND hora <= 20 THEN 'Evening'
        WHEN hora > 20 AND hora <= 24 THEN 'Night'
        WHEN hora <= 4 THEN 'Late Night'
    END AS part_of_day,
    COUNT(DISTINCT order_id) AS Num_Pedidos
FROM pedidos_table
WHERE campanha = 'Nome_da_Campanha'
AND data_pedido BETWEEN '2024-01-01' AND '2024-03-31' 
GROUP BY part_of_day;

/* Usuários que não tem compra em dezembro de 2022 */
select distinct
  u.id
from bigquery-public-data.thelook_ecommerce.users u
left join bigquery-public-data.thelook_ecommerce.orders o on u.id = o.user_id and date(o.created_at) between "2022-12-01" and "2022-12-31"
where o.user_id is null;

/* Ticket Médio de Pedidos (marketing pode selecionar usuários com uma certa faixa especifica para uma campanha especifica) */
/* Mede o valor médio gasto por pedido, indicando o poder de compra dos clientes e o desempenho das vendas. */
SELECT
  user_id,
  AVG(receita) AS ticket_medio
FROM (
  SELECT 
    order_id,
    user_id,
    ROUND(SUM(sale_price), 2) AS receita 
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE status = 'Complete'
  GROUP BY 1, 2
)
GROUP BY 1
ORDER BY 2 DESC

/* Tempo em dias da data de cadastro até a última compra de cada usuário. O time de marketing pode fazer uma ação/campanha focado nestes maiores usuários. */
SELECT
  u.id,
  MAX(timestamp_diff(o.created_at, u.created_at, DAY)) AS dias_ate_ultima_compra
FROM bigquery-public-data.thelook_ecommerce.orders o
JOIN bigquery-public-data.thelook_ecommerce.users u ON u.id = o.user_id
GROUP BY 1
ORDER BY 2 DESC;

/* Tempo em dias entre a primeira e a última compra de cada usuário. O time de marketing pode fazer uma ação/campanha focado nestes maiores usuários. */
SELECT
  user_id,
  timestamp_diff(MAX(created_at), MIN(created_at), DAY) AS dias_entre_prim_ult
FROM bigquery-public-data.thelook_ecommerce.orders
GROUP BY 1
ORDER BY 2 DESC;

/* Forma de retornar os usuários com compras recorrentes dentro do mesmo mês (mais de 1 compra). O time de marketing pode fazer uma campanha focada em usuarios mais fiéis aumentando a previsibilidade do resultado */
SELECT DISTINCT user_id
FROM (
  SELECT
    user_id,
    order_id,
    created_at,
    ROW_NUMBER() OVER (
      PARTITION BY user_id, EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
      ORDER BY created_at
    ) AS numero_compra
  FROM bigquery-public-data.thelook_ecommerce.orders
) AS T
WHERE numero_compra > 1
ORDER BY user_id;

/* 
### Análise RFM - Segmentação de Clientes:
A análise RFM é uma técnica de marketing usada para quantificar o valor de um cliente com base em três aspectos específicos do seu comportamento de compra. RFM significa:

- Recência (R): Há quanto tempo o cliente fez a última compra. Clientes que compraram recentemente são mais propensos a comprar novamente em comparação com aqueles que não compram há muito tempo.
- Frequência (F): Com que frequência o cliente compra dentro de um determinado período. Clientes que compram com frequência são considerados mais engajados e valiosos.
- Monetário (M): O valor monetário total gasto pelo cliente. Clientes que gastam mais são vistos como mais valiosos.

A combinação desses três indicadores ajuda as empresas a identificar quais clientes são mais valiosos e a personalizar as estratégias de marketing para diferentes segmentos de clientes, de acordo com suas características de compra. 
Por exemplo, um cliente que fez uma compra recentemente, compra com frequência e gasta muito é idealmente o mais valioso para a empresa e provavelmente será o foco de campanhas de marketing intensivas.
*/

/* Aqui está um exemplo de query SQL que calcula os scores de Recência, Frequência e Monetário para cada cliente: */

WITH Recency AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase
    FROM sales
    GROUP BY customer_id
),

Frequency AS (
    SELECT
        customer_id,
        COUNT(*) AS total_purchases
    FROM sales
    GROUP BY customer_id
),

Monetary AS (
    SELECT
        customer_id,
        SUM(order_value) AS total_spent
    FROM sales
    GROUP BY customer_id
)

SELECT
    R.customer_id,
    R.last_purchase AS recency,
    F.total_purchases AS frequency,
    M.total_spent AS monetary
FROM Recency R
JOIN Frequency F ON R.customer_id = F.customer_id
JOIN Monetary M ON R.customer_id = M.customer_id;

/* 
### Explicação:

1. Recency: A CTE (Common Table Expression) `Recency` calcula a data mais recente de compra para cada cliente.
2. Frequency: A CTE `Frequency` conta o número total de compras feitas por cada cliente.
3. Monetary: A CTE `Monetary` soma o valor total gasto por cada cliente.
4. Join Final: Essas três CTEs são então combinadas para fornecer um único resultado com `customer_id`, recência (data da última compra), frequência (total de compras) e monetário (total gasto).

Esse SQL te dá uma tabela básica de RFM que você pode usar para segmentar seus clientes e desenvolver estratégias de marketing personalizadas com base em seus comportamentos de compra.
*/

/*
A partir da tabela básica de RFM que criamos anteriormente, podemos segmentar os clientes com base em critérios definidos para Recência, Frequência e Monetário. Aqui está uma abordagem simples para categorizar cada um dos aspectos em três níveis: Alto, Médio e Baixo.

Vamos supor que você tenha calculado ou definido alguns limites para cada categoria com base em sua distribuição de dados ou necessidades de negócios. Por exemplo:

- Recência: Menos dias desde a última compra = mais recente = melhor
  - Alto: até 30 dias
  - Médio: 31 a 90 dias
  - Baixo: mais de 90 dias

- Frequência: Mais compras = melhor
  - Alto: 10 ou mais compras
  - Médio: 4 a 9 compras
  - Baixo: menos de 4 compras

- Monetário: Mais gasto = melhor
  - Alto: mais de R$500
  - Médio: R$200 a R$500
  - Baixo: menos de R$200

Aqui está uma query SQL que utiliza esses critérios para segmentar os clientes:

### Explicação:
- Recency_Score, Frequency_Score, Monetary_Score: Calcula a pontuação de Recência, Frequência e Monetário para cada cliente.
- RFM_Class: Concatena as pontuações de Recência, Frequência e Monetário para criar uma classificação RFM combinada, que pode ser usada para identificar segmentos de clientes de alto valor, médio e baixo.

Essa segmentação ajuda você a entender melhor seus clientes e a otimizar suas estratégias de marketing e comunicação com base no comportamento de compra dos clientes.
Ela ermite desenvolver estratégias de marketing personalizadas para cada segmento, como oferecer promoções específicas para aumentar a frequência de compras dos clientes esporádicos ou manter o engajamento dos clientes mais valiosos.
*/

WITH RFM AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase,
        COUNT(*) AS total_purchases,
        SUM(order_value) AS total_spent
    FROM sales
    GROUP BY customer_id
),

RFM_Segmentation AS (
    SELECT
        customer_id,
        last_purchase,
        total_purchases,
        total_spent,
        -- Recency Score
        CASE
            WHEN last_purchase >= CURRENT_DATE - INTERVAL '30' DAY THEN 'Alto'
            WHEN last_purchase < CURRENT_DATE - INTERVAL '30' DAY AND last_purchase >= CURRENT_DATE - INTERVAL '90' DAY THEN 'Médio'
            ELSE 'Baixo'
        END AS Recency_Score,
        -- Frequency Score
        CASE
            WHEN total_purchases >= 10 THEN 'Alto'
            WHEN total_purchases >= 4 AND total_purchases < 10 THEN 'Médio'
            ELSE 'Baixo'
        END AS Frequency_Score,
        -- Monetary Score
        CASE
            WHEN total_spent > 500 THEN 'Alto'
            WHEN total_spent BETWEEN 200 AND 500 THEN 'Médio'
            ELSE 'Baixo'
        END AS Monetary_Score
    FROM RFM
)

SELECT
    *,
    Recency_Score,
    Frequency_Score,
    Monetary_Score,
    -- Overall RFM Score
    CONCAT(Recency_Score, Frequency_Score, Monetary_Score) AS RFM_Class
FROM RFM_Segmentation;

