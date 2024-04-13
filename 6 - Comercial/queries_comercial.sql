/* 1 - Volume de Pedidos por Região */
/* Monitora a demanda em diferentes áreas geográficas, permitindo ajustes na estratégia de oferta e promoções. */
SELECT regiao, COUNT(DISTINCT order_id) AS volume_pedidos
FROM pedidos
GROUP BY regiao
ORDER BY volume_pedidos DESC;

/* 2 - Vendas por segmentação de parte do dia */
SELECT 
    EXTRACT(HOUR FROM hora_venda) AS hora,
    CASE 
        WHEN EXTRACT(HOUR FROM hora_venda) BETWEEN 6 AND 10 THEN 'Café da manhã'
        WHEN EXTRACT(HOUR FROM hora_venda) BETWEEN 11 AND 14 THEN 'Almoço'
        WHEN EXTRACT(HOUR FROM hora_venda) BETWEEN 15 AND 17 THEN 'Snack'
        WHEN EXTRACT(HOUR FROM hora_venda) BETWEEN 18 AND 22 THEN 'Jantar'
        ELSE 'Outro'
    END AS segmento_dia,
    EXTRACT(YEAR FROM hora_venda) AS ano,
    COUNT(DISTINCT order_id) AS num_vendas
FROM vendas
GROUP BY hora, segmento_dia, ano
ORDER BY segmento_dia, hora, ano;

/* 3 - Gross Merchandise Volume (GMV): Total bruto de vendas de produtos ou serviços, representando a saúde financeira geral da plataforma. */
SELECT 
    EXTRACT(MONTH FROM data_venda) AS mes,
    EXTRACT(YEAR FROM data_venda) AS ano,
    SUM(valor_total_pedido) AS gmv
FROM pedidos
GROUP BY mes, ano
ORDER BY ano, mes;

/* 4 - Ticket Médio de Pedidos */
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

/* 5 - Preço médio de Produto - Por Estado */
/* Pode fornecer insights valiosos sobre as variações de preço em diferentes regiões e o desempenho das marcas em cada mercado estadual. */
SELECT 
    estado,
    marca,
    AVG(preco) AS preco_medio
FROM tabela_de_vendas
WHERE data_venda BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY estado, marca;

/* 6 - Análise de Satisfação dos Clientes */
/* Avalia a experiência dos usuários por meio de avaliações e feedbacks, influenciando a reputação da empresa. */
SELECT AVG(avaliacao) AS satisfacao_media
FROM feedback_clientes;

/* 7 - Taxa de Retenção de Clientes */
/* Mensura a capacidade de manter os usuários ativos na plataforma ao longo do tempo. */
SELECT (COUNT(DISTINCT clientes_ativos_mes_atual) / COUNT(DISTINCT clientes_ativos_mes_anterior) - 1) AS taxa_retencão
FROM clientes_ativos;

/* 8 - Top 10 clientes que mais compraram, por região */
SELECT 
    regiao,
    cliente_id,
    COUNT(DISTINCT order_id) AS num_compras
FROM vendas
GROUP BY regiao, cliente_id
ORDER BY num_compras DESC
LIMIT 10;

/* 9 - Top 10 Produtos Mais Vendidos */
SELECT produto, COUNT(DISTINCT order_id) AS num_vendas
FROM vendas
GROUP BY produto
ORDER BY num_vendas DESC
LIMIT 10;

/* 10 - Número de clientes por mês */
SELECT 
    EXTRACT(MONTH FROM data_registro) AS mes,
    EXTRACT(YEAR FROM data_registro) AS ano,
    COUNT(DISTINCT client_id) AS num_clientes
FROM clientes
GROUP BY mes, ano
ORDER BY ano, mes;

/* 11 - Número de pedidos por mês */
SELECT 
    EXTRACT(MONTH FROM data_pedido) AS mes,
    EXTRACT(YEAR FROM data_pedido) AS ano,
    COUNT(DISTINCT order_id) AS num_pedidos
FROM pedidos
GROUP BY mes, ano
ORDER BY ano, mes;

/* 12 - Usuários que não tem compra em dezembro de 2022 */
select distinct
  u.id
from bigquery-public-data.thelook_ecommerce.users u
left join bigquery-public-data.thelook_ecommerce.orders o on u.id = o.user_id and date(o.created_at) between "2022-12-01" and "2022-12-31"
where o.user_id is null;

/* 13 - informações resumidas sobre os usuários (de todos, tendo ou não compras). 
- Id do usuário
- Quantidade de compras realizadas
- Quantidade de itens comprados
- Ticket médio
- Quantidade de produtos distintos comprados
- Centro de distribuições dos quais o usuário recebeu produtos
- Quantidade de criações de carrinho. 
*/
select
  u.id,
  ticket_medio,
  compras_realizadas,
  itens_comprados,
  produtos_distintos,
  centros_distribuicao,
  count(distinct e.id) as eventos_carrinho
from bigquery-public-data.thelook_ecommerce.users u
left join bigquery-public-data.thelook_ecommerce.events e on e.user_id = u.id and event_type = 'cart'
left join (
  select
    o.user_id,
    sum(sale_price)/count(distinct o.order_id) as ticket_medio,
    count(distinct o.order_id) as compras_realizadas,
    count(distinct oi.id) as itens_comprados,
    count(distinct p.id) as produtos_distintos,
    count(distinct d.id) as centros_distribuicao
  from bigquery-public-data.thelook_ecommerce.orders o
  left join bigquery-public-data.thelook_ecommerce.order_items oi on o.order_id = oi.order_id
  left join bigquery-public-data.thelook_ecommerce.products p on p.id = oi.product_id
  left join bigquery-public-data.thelook_ecommerce.distribution_centers d on d.id = p.distribution_center_id
  group by 1
) as T on T.user_id = u.id
group by 1, 2, 3, 4, 5, 6
order by id;

/* 14 - Tempo em dias da data de cadastro até a última compra de cada usuário. */
select
  u.id,
  max(timestamp_diff(o.created_at, u.created_at, day)) as dias_ate_ultima_compra
from bigquery-public-data.thelook_ecommerce.orders o
join bigquery-public-data.thelook_ecommerce.users u on u.id = o.user_id
group by 1
order by 2 desc;

/* 15 - Tempo em dias entre a primeira e a última compra de cada usuário.*/
select
  user_id,
  timestamp_diff(max(created_at), min(created_at), day) as dias_entre_prim_ult
from bigquery-public-data.thelook_ecommerce.orders
group by 1
order by 2 desc;

/* 16 - Receita acumulada dos usuários, a cada pedido. */
select
  o.user_id,
  o.order_id,
  oi.id as item_id,
  o.created_at,
  round(sum(sale_price) over(partition by o.user_id order by o.created_at, oi.id rows between unbounded preceding and current row), 2) as receita_acumulada
from bigquery-public-data.thelook_ecommerce.orders o
join bigquery-public-data.thelook_ecommerce.order_items oi on oi.order_id = o.order_id
order by 1, 4, 3;

/* 17 - Tempo em dias entre uma compra e outra para cada usuário */
select
    user_id,
    order_id,
    created_at,
    timestamp_diff(created_at, lag(created_at) over(partition by user_id order by created_at), day) diferenca_dias
from bigquery-public-data.thelook_ecommerce.orders
order by 1, 3
-- order by 4 desc (para mostrar usuarios com maior diferenca em dias)

/* 18 - Forma de retornar os usuários com compras recorrentes dentro do mesmo mês (mais de 1 compra) */
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
