/* Taxa de Entrega no Prazo: Porcentagem de pedidos entregues dentro do tempo estimado. */
SELECT COUNT(*) AS TotalPedidos,
       SUM(CASE WHEN entrega_no_prazo = 1 THEN 1 ELSE 0 END) AS PedidosEntreguesNoPrazo,
       (PedidosEntreguesNoPrazo / TotalPedidos) * 100 AS TaxaEntregaNoPrazo
FROM Pedidos;

/* Eficiência de Logística: Tempo médio de preparo e entrega dos pedidos. */
SELECT AVG(tempo_preparo + tempo_entrega) AS TempoMedioLogistica
FROM Pedidos;

/* Taxa de Pedidos Atrasados: Porcentagem de pedidos que não foram entregues dentro do tempo estimado. */
SELECT (COUNT(*) / (SELECT COUNT(*) FROM Pedidos)) * 100 AS TaxaPedidosAtrasados
FROM Pedidos
WHERE entrega_no_prazo = 0;

/* Utilização de Recursos: Percentual de utilização dos recursos de entrega (motos, bicicletas, etc.). */
SELECT recurso_entrega,
       COUNT(*) AS TotalPedidos,
       (COUNT(*) / (SELECT COUNT(*) FROM Pedidos)) * 100 AS UtilizacaoRecursos
FROM Pedidos
GROUP BY recurso_entrega;

/* Taxa de Devoluções: Porcentagem de pedidos devolvidos pelos clientes. */
SELECT (COUNT(*) / (SELECT COUNT(*) FROM Pedidos)) * 100 AS TaxaDevolucoes
FROM Pedidos
WHERE status_pedido = 'Devolvido';

/* Custo de Logística por Pedido: Custo médio de logística por pedido entregue. */
SELECT AVG(custo_logistica) AS CustoLogisticaPorPedido
FROM Pedidos;
