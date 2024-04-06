/* EBITDA (Earnings Before Interest, Taxes, Depreciation, and Amortization) Ele representa os ganhos operacionais da empresa, excluindo os efeitos de itens não operacionais, como juros, impostos, depreciação e amortização.*/
-- EBITDA Mensal
SELECT
    DATE_TRUNC('month', data_pedido) AS mes,
    SUM(valor_total - custo_produtos - custo_operacional) AS ebitda
FROM pedidos
GROUP BY mes
ORDER BY mes;

/* Margem de Lucro Líquido: Essa métrica calcula a porcentagem de lucro líquido obtido em relação à receita total. Ela leva em consideração todos os custos, incluindo impostos e despesas operacionais. */
-- Margem de Lucro Líquido Mensal
SELECT
    DATE_TRUNC('month', data_pedido) AS mes,
    (SUM(valor_total - custo_produtos - custo_operacional - impostos) / SUM(valor_total)) AS margem_lucro_liquido
FROM pedidos
GROUP BY mes
ORDER BY mes;

/* Gross Merchandise Volume (GMV): Total bruto de vendas de produtos ou serviços, representando a saúde financeira geral da plataforma. */
-- GMV Mensal
SELECT
    DATE_TRUNC('month', data_pedido) AS mes,
    SUM(valor_total) AS gmv
FROM pedidos
GROUP BY mes
ORDER BY mes;

/* Taxa de Comissão Média: Média da taxa cobrada dos restaurantes em relação ao GMV, indicando a eficácia na monetização do serviço. */
-- Taxa de Comissão Média Mensal
SELECT
    DATE_TRUNC('month', data_pedido) AS mes,
    AVG(taxa_comissao) AS taxa_comissao_media
FROM pedidos
GROUP BY mes 
ORDER BY mes;

/* Churn Rate de Restaurantes: Taxa de rotatividade de restaurantes parceiros, que pode indicar satisfação, competitividade e atratividade da plataforma. */
-- Churn Rate de Restaurantes Mensal
SELECT
    DATE_TRUNC('month', data_ultimo_pedido) AS mes,
    COUNT(DISTINCT restaurante_id) AS restaurantes_ativos,
    COUNT(DISTINCT CASE WHEN data_ultimo_pedido < CURRENT_DATE - INTERVAL '30 days' THEN restaurante_id END) AS restaurantes_churn
FROM pedidos
GROUP BY mes
ORDER BY mes;

/* Lifetime Value (LTV) do Cliente: Valor médio que um cliente gera durante todo o tempo que utiliza o serviço, importante para avaliar a rentabilidade e retenção de clientes. */
-- LTV do Cliente
SELECT
    cliente_id,
    AVG(valor_total) AS ltv
FROM pedidos
GROUP BY cliente_id;

/* Margem de Lucro Bruto: Porcentagem de receita retida após a dedução dos custos de bens vendidos, indicando a eficiência operacional e rentabilidade. */
-- Margem de Lucro Bruto Mensal
SELECT
    DATE_TRUNC('month', data_pedido) AS mes,
    SUM(valor_total - custo_produtos) / SUM(valor_total) AS margem_lucro_bruto
FROM pedidos
GROUP BY mes
ORDER BY mes;

/* Custo de Aquisição de Cliente (CAC): Investimento médio necessário para adquirir um novo cliente, essencial para avaliar a eficácia das estratégias de marketing e vendas. */
-- CAC Mensal
SELECT
    DATE_TRUNC('month', data_cadastro) AS mes,
    SUM(custo_campanhas + custo_vendas) / COUNT(DISTINCT cliente_id) AS cac_mensal
FROM clientes
GROUP BY mes
ORDER BY mes;

