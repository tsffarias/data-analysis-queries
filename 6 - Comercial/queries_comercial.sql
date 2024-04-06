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
SELECT AVG(valor_total_pedido) AS ticket_medio
FROM pedidos;

/* 5 - Análise de Satisfação dos Clientes */
/* Avalia a experiência dos usuários por meio de avaliações e feedbacks, influenciando a reputação da empresa. */
SELECT AVG(avaliacao) AS satisfacao_media
FROM feedback_clientes;

/* 6 - Taxa de Retenção de Clientes */
/* Mensura a capacidade de manter os usuários ativos na plataforma ao longo do tempo. */
SELECT (COUNT(DISTINCT clientes_ativos_mes_atual) / COUNT(DISTINCT clientes_ativos_mes_anterior) - 1) AS taxa_retencão
FROM clientes_ativos;

/* 7 - Top 10 clientes que mais compraram, por região */
SELECT 
    regiao,
    cliente_id,
    COUNT(DISTINCT order_id) AS num_compras
FROM vendas
GROUP BY regiao, cliente_id
ORDER BY num_compras DESC
LIMIT 10;

/* 8 - Top 10 Produtos Mais Vendidos */
SELECT produto, COUNT(DISTINCT order_id) AS num_vendas
FROM vendas
GROUP BY produto
ORDER BY num_vendas DESC
LIMIT 10;

/* 9 - Número de clientes por mês */
SELECT 
    EXTRACT(MONTH FROM data_registro) AS mes,
    EXTRACT(YEAR FROM data_registro) AS ano,
    COUNT(DISTINCT client_id) AS num_clientes
FROM clientes
GROUP BY mes, ano
ORDER BY ano, mes;

/* 10 - Número de pedidos por mês */
SELECT 
    EXTRACT(MONTH FROM data_pedido) AS mes,
    EXTRACT(YEAR FROM data_pedido) AS ano,
    COUNT(DISTINCT order_id) AS num_pedidos
FROM pedidos
GROUP BY mes, ano
ORDER BY ano, mes;