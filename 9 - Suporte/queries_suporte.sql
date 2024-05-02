/* 
** QUERIES DEPARTAMENTO DE SUPORTE **

- Esses KPIs são essenciais para monitorar a eficácia e eficiência do suporte, além de ajudar na tomada de decisões para melhorar continuamente o serviço oferecido aos usuários.
*/

/* Tempo Médio de Resolução
Descrição: Mede o tempo médio necessário para resolver um ticket desde sua abertura até sua conclusão.
*/
SELECT AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at)) AS tempo_medio_resolucao
FROM tickets_suporte
WHERE resolved_at IS NOT NULL AND data BETWEEN '2024-04-01' AND '2024-04-30';

/* Tempo Médio de Resposta (TMR)
Descrição: Mede o tempo médio que leva para o suporte inicialmente responder a um ticket após sua criação. 
*/
SELECT AVG(TIMESTAMPDIFF(MINUTE, created_at, first_response_at)) AS tempo_medio_resposta
FROM tickets_suporte
WHERE data BETWEEN '2024-04-01' AND '2024-04-30';

/* Taxa de Satisfação do Cliente (CSAT)
Descrição: Percentual de clientes que classificaram o serviço como 'Bom' ou 'Excelente'.
*/
SELECT (COUNT(*) FILTER (WHERE satisfaction IN ('Bom', 'Excelente')) * 100.0 / COUNT(*)) AS taxa_satisfacao
FROM avaliacoes_suporte
WHERE data_avaliacao BETWEEN '2024-04-01' AND '2024-04-30';

/* Primeira Taxa de Resolução de Contato (FCR)
Descrição: Percentual de tickets resolvidos na primeira interação com o cliente.
*/
SELECT (COUNT(*) FILTER (WHERE resolvido_primeiro_contato = TRUE) * 100.0 / COUNT(*)) AS fcr
FROM tickets_suporte
WHERE data BETWEEN '2024-04-01' AND '2024-04-30';

/* Taxa de Reabertura de Tickets
Descrição: Percentual de tickets que foram reabertos após serem marcados como resolvidos.
*/
SELECT (COUNT(*) FILTER (WHERE reaberto = TRUE) * 100.0 / COUNT(*)) AS taxa_reabertura
FROM tickets_suporte
WHERE data BETWEEN '2024-04-01' AND '2024-04-30';

/* Volume de Tickets
Descrição: Número total de tickets recebidos por período.
*/
SELECT data, COUNT(*) AS volume_tickets
FROM tickets_suporte
GROUP BY data
ORDER BY data;

/* Percentual de Tickets Escalados
Descrição: Mede o percentual de tickets que precisam ser encaminhados para equipes especializadas ou de nível superior.
*/
SELECT (COUNT(*) FILTER (WHERE escalado = TRUE) * 100.0 / COUNT(*)) AS percentual_escalados
FROM tickets_suporte
WHERE data BETWEEN '2024-04-01' AND '2024-04-30';

/* Eficiência do Suporte
Descrição: Avalia a capacidade de resolver tickets dentro de um determinado período, comparando com o número total de tickets.
*/
SELECT data, (COUNT(*) FILTER (WHERE resolvido = TRUE) * 100.0 / COUNT(*)) AS eficiencia_suporte
FROM tickets_suporte
GROUP BY data
ORDER BY data;

/* Média de Interações por Ticket
Descrição: Número médio de interações (mensagens, emails, ligações) por ticket antes de serem resolvidos.
*/
SELECT AVG(numero_interacoes) AS media_interacoes
FROM tickets_suporte
WHERE data BETWEEN '2024-04-01' AND '2024-04-30';

/* Tempo de Espera Médio
Descrição: Tempo médio que os clientes esperam na fila antes de receberem suporte.
*/
SELECT AVG(TIMESTAMPDIFF(MINUTE, created_at, first_contact_at)) AS tempo_espera_medio
FROM tickets_suporte
WHERE first_contact_at IS NOT NULL AND data BETWEEN '2024-04-01' AND '2024-04-30';




















