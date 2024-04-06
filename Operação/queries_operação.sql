/* 1 - Taxa de Retenção de Clientes: Porcentagem de clientes que continuam utilizando o serviço após o primeiro pedido. */
SELECT (COUNT(DISTINCT cliente_id) / (SELECT COUNT(DISTINCT cliente_id) FROM Pedidos)) * 100 AS TaxaRetencaoClientes
FROM Pedidos
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-03-31';

/* 2 - Índice de Satisfação do Cliente: Avaliação média dos clientes sobre o serviço. */
SELECT AVG(avaliacao_cliente) AS IndiceSatisfacaoCliente
FROM Avaliacoes;

/* 3 - Eficiência de Logística: Tempo médio de preparo e entrega dos pedidos. */
SELECT AVG(tempo_preparo + tempo_entrega) AS TempoMedioLogistica
FROM Pedidos;

/* 4 - Taxa de Entrega no Prazo: Porcentagem de pedidos entregues dentro do tempo estimado. */
SELECT COUNT(*) AS TotalPedidos,
       SUM(CASE WHEN entrega_no_prazo = 1 THEN 1 ELSE 0 END) AS PedidosEntreguesNoPrazo,
       (PedidosEntreguesNoPrazo / TotalPedidos) * 100 AS TaxaEntregaNoPrazo
FROM Pedidos;


/* 5 - Taxa de Pedidos Cancelados: Porcentagem de pedidos que são cancelados antes da entrega. */
SELECT (COUNT(*) / (SELECT COUNT(*) FROM Pedidos)) * 100 AS TaxaPedidosCancelados
FROM Pedidos
WHERE status_pedido = 'Cancelado';

/* 6 - Utilização de Recursos: Percentual de utilização dos recursos de entrega (motos, bicicletas, etc.). */
SELECT recurso_entrega,
       COUNT(*) AS TotalPedidos,
       (COUNT(*) / (SELECT COUNT(*) FROM Pedidos)) * 100 AS UtilizacaoRecursos
FROM Pedidos
GROUP BY recurso_entrega;

/* 7 - Taxa de utilização de equipamentos: Avalia a eficiência na utilização dos equipamentos em relação ao tempo disponível. */
SELECT (SUM(tempo_utilizado) / SUM(tempo_disponivel)) AS equipment_utilization_rate
FROM equipment_table;

/* 8 - Nível de estoque médio: Mostra a média do estoque disponível em um determinado período de tempo. */
SELECT AVG(estoque_disponivel) AS avg_inventory_level
FROM inventory_table;

/* 9 - Taxa de retrabalho: Indica a proporção de produtos ou serviços que precisaram ser retrabalhados. */
SELECT (COUNT(retrabalho) / COUNT(*)) AS rework_rate
FROM operations_table;

/* 10 - Taxa de eficiência da produção: Avalia a eficácia da produção em relação à capacidade máxima. */
SELECT (SUM(produto_produzido) / MAX(capacidade)) AS production_efficiency
FROM production_table;

/* 11 - Tempo médio de ciclo de operação: Mede o tempo necessário para concluir um ciclo completo de operações, desde o início até o fim. */
SELECT AVG(DATEDIFF(complete_date, start_date)) AS avg_cycle_time
FROM operations_table;

