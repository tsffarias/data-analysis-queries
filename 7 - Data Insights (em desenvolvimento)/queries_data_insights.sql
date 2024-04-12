/* 1 - Market Basket Analysis - Crossbasket (Análise de Cesta de Compras): Identifica padrões de compra e associações entre os itens comprados pelos clientes. */
/* Explicação da Query:
- Paired_Products: Esta CTE cria pares de produtos que foram comprados juntos no mesmo pedido. A condição oi1.product_id < oi2.product_id garante que cada combinação seja contada apenas uma vez e evita duplicidade.
- Product_Combinations: Agrupa esses pares para contar quantas vezes cada par de produtos foi pedido.
- Total_Orders_Per_Product: Conta quantos pedidos contêm cada produto individualmente.
- Consulta Final: Calcula a porcentagem de pedidos contendo o produto menos frequente no par que também inclui o outro produto do par. Isso é feito dividindo o número de pedidos que contêm ambos os produtos pela quantidade total de pedidos do produto menos comum no par. Os resultados são ordenados por order_count para destacar os pares mais comuns.
💡 Essa análise ajuda a identificar oportunidades para promoções cruzadas ou recomendações de produtos baseadas em padrões de compra observados, aumentando potencialmente as vendas e a satisfação do cliente ao antecipar suas necessidades.
*/

WITH Paired_Products AS (
    SELECT 
        oi1.order_id, 
        oi1.product_id AS product_id1, 
        oi2.product_id AS product_id2
    FROM 
        `bigquery-public-data.thelook_ecommerce.order_items` oi1
    JOIN 
        `bigquery-public-data.thelook_ecommerce.order_items` oi2 
        ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
    WHERE 
        oi1.status = 'Complete' AND oi2.status = 'Complete'
),
Product_Combinations AS (
    SELECT 
        product_id1, 
        product_id2, 
        COUNT(DISTINCT order_id) AS order_count
    FROM 
        Paired_Products
    GROUP BY 
        product_id1, product_id2
),
Total_Orders_Per_Product AS (
    SELECT 
        product_id, 
        COUNT(DISTINCT order_id) AS total_orders
    FROM 
        `bigquery-public-data.thelook_ecommerce.order_items`
    WHERE 
        status = 'Complete'
    GROUP BY 
        product_id
)

SELECT 
    pc.product_id1,
    pc.product_id2,
    pc.order_count,
    ROUND((CAST(pc.order_count AS FLOAT64) / MIN(tp.total_orders)) * 100, 2) AS percentage
FROM 
    Product_Combinations pc
JOIN 
    Total_Orders_Per_Product tp ON pc.product_id1 = tp.product_id OR pc.product_id2 = tp.product_id
GROUP BY 
    pc.product_id1, pc.product_id2, pc.order_count
ORDER BY 
    pc.order_count DESC;



/* 2 - Taxa de Churn: Mede a proporção de clientes que cancelam ou não renovam seus serviços em um determinado período de tempo. */

/* 3 - Lifetime Value (LTV) dos Clientes: Representa o valor líquido que um cliente contribui para a empresa durante todo o seu relacionamento com ela. */

/* 4 - Custo de Aquisição de Clientes (CAC): Mostra o custo médio de adquirir um novo cliente para a empresa. */

/* 5 - Lifetime Value (LTV) dos Clientes: Representa o valor líquido que um cliente contribui para a empresa durante todo o seu relacionamento com ela. */

/* 6 - Taxa de Conversão: Indica a proporção de usuários que realizam uma ação desejada, como fazer um pedido, em relação ao número total de usuários. */

/* 7 - Taxa de Engajamento do Usuário: Avalia o nível de interação dos usuários com a plataforma ou aplicativo. */

/* 8 - Análise de Cohort: Agrupa os clientes com base em características semelhantes para analisar seu comportamento ao longo do tempo. */

/* 9 - Tempo Médio de Resposta (MTTR): Mede o tempo médio necessário para resolver problemas ou responder a solicitações dos clientes. */

/* 10 - Taxa de Retenção de Usuários: Essa métrica mede a capacidade da empresa de manter seus clientes ao longo do tempo. */

