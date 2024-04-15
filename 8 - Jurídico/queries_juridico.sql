/* 
** QUERIES DEPARTAMENTO JURIDICO **

# Dicionário de termos:
- Litígios: se referem a disputas legais ou controvérsias que são resolvidas em um tribunal ou através de arbitragem. No contexto jurídico, 
um litígio pode envolver qualquer tipo de conflito legal, como disputas contratuais, questões trabalhistas, violações de direitos autorais, reclamações de consumidores, e mais. 
Esses processos podem ser civis ou criminais, e geralmente envolvem duas ou mais partes que buscam uma solução legal para o seu desacordo.
*/

/* Número de Litígios por Período: Mede a quantidade de novos processos legais iniciados contra ou pela empresa em um determinado período.*/
SELECT EXTRACT(MONTH FROM data_registro) AS mes, COUNT(DISTINCT processo_legal_id) AS TotalLitigios
FROM processos
WHERE DataInicio BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 1
ORDER BY 1 DESC;

/* Taxa de Sucesso em Litígios: Percentual de casos ganhos em relação ao total de casos concluídos. */
SELECT (SUM(CASE WHEN Resultado = 'Ganho' THEN 1 ELSE 0 END) / COUNT(DISTINCT processo_legal_id)) * 100 AS TaxaSucesso
FROM processos
WHERE DataFim IS NOT NULL;

/* Custo Médio por Litígio: Média de custos associados a litígios, incluindo advogados, taxas e outros encargos. */
SELECT AVG(CustoTotal) AS CustoMedio
FROM processos;

/* Tempo Médio de Resolução de Casos: Tempo médio entre a data de início e a data de conclusão de um caso.*/
SELECT AVG(DATEDIFF(DataFim, DataInicio)) AS TempoMedioResolucao
FROM processos
WHERE DataFim IS NOT NULL;

/* Processos por Categoria: Distribuição de processos legais por tipo (ex.: trabalhista, civil, regulatório).*/
SELECT Tipo, COUNT(DISTINCT processo_legal_id) AS Quantidade
FROM processos
GROUP BY Tipo
ORDER BY 2 DESC;;

/* Percentual de Acordos: Percentual de processos que terminam em acordo antes do julgamento.*/
SELECT 
  (COUNT(DISTINCT CASE WHEN Resultado = 'Acordo' THEN processo_legal_id END) / COUNT(DISTINCT processo_legal_id)) * 100 AS PercentualAcordos
FROM processos
WHERE DataFim IS NOT NULL;

/* Lista de Contratos Próximos do Vencimento: Identifica contratos que estão próximos do término, permitindo ações proativas para renovação ou renegociação.*/
SELECT ContratoID, NomeFornecedor, DataInicio, DataFim
FROM contratos
WHERE DataFim BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 3 MONTH)
ORDER BY DataFim;

/* Contratos Vencidos e Não Renovados: Encontra contratos cujo prazo de validade expirou, mas que ainda não foram renovados ou encerrados.*/
SELECT ContratoID, NomeFornecedor, DataInicio, DataFim
FROM contratos
WHERE DataFim < CURRENT_DATE AND Renovado = 'Não'
ORDER BY DataFim;

/* Resumo dos Contratos por Fornecedor: Oferece uma visão geral de todos os contratos ativos e encerrados para cada fornecedor, facilitando a gestão de relações. */
SELECT 
	NomeFornecedor, 
	COUNT(DISTINCT ContratoID) AS TotalContratos, 
	SUM(CASE WHEN DataFim >= CURRENT_DATE THEN 1 ELSE 0 END) AS ContratosAtivos
FROM contratos
GROUP BY NomeFornecedor;

/* Detalhes dos Contratos com Cláusulas Específicas: Identifica contratos que contêm cláusulas específicas que podem exigir atenção especial, como cláusulas de penalidade ou exclusividade.*/
SELECT ContratoID, NomeFornecedor, Detalhes
FROM contratos
WHERE Detalhes LIKE '%penalidade%' OR Detalhes LIKE '%exclusividade%';

/* Acompanhamento de Alterações Contratuais: Rastreia histórico de modificações nos contratos, importante para auditorias e conformidade regulatória.*/
SELECT ContratoID, DataModificacao, ModificadoPor, DescricaoModificacao
FROM historico_modificacoes_contratos
ORDER BY DataModificacao DESC;
