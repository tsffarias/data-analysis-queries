/* 1- Taxa de Rotatividade (Turnover Rate) */
/* KPI: Turnover Rate = (Número de Desligamentos / Média de Funcionários) * 100 */

SELECT 
  (COUNT(DISTINCT employee_id) / AVG(total_employees)) * 100 AS turnover_rate
FROM 
  employee_departures, total_employees
WHERE 
  departure_date BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';

/* 2 - Custo de Contratação (Cost Per Hire) */
/* KPI: Cost Per Hire = (Custo Total de Contratação / Número de Contratações) */

SELECT 
  SUM(cost) / COUNT(DISTINCT hire_id) AS cost_per_hire
FROM 
  hiring_costs
WHERE 
  hire_date BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';

/* 3 - Índice de Satisfação dos Funcionários (Employee Satisfaction Index) */
/* KPI: Calculado através de pesquisas e análises de sentimentos. SQL: Dependente da estrutura de dados de pesquisa. */
/* O Índice de Satisfação dos Funcionários geralmente é calculado com base em pesquisas e questionários. Supondo que exista uma tabela employee_surveys com campos como employee_id, survey_date, satisfaction_score (onde a pontuação de satisfação é quantificada), a query SQL poderia ser: */

SELECT 
  AVG(satisfaction_score) AS employee_satisfaction_index
FROM 
  employee_surveys
WHERE 
  survey_date BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';


/* 4 - Tempo Médio para Preencher Vagas (Time to Fill) */
/* KPI: Time to Fill = (Data de Preenchimento - Data de Abertura da Vaga) */

SELECT 
  AVG(DATEDIFF(fill_date, open_date)) AS time_to_fill
FROM 
  job_openings
WHERE 
  fill_date BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';

/* 5 - Índice de Absenteísmo (Absenteeism Rate) */
/* KPI: Absenteeism Rate = (Dias Perdidos / Total de Dias Trabalháveis) * 100 */
SELECT 
  (SUM(absent_days) / SUM(working_days)) * 100 AS absenteeism_rate
FROM 
  attendance_records
WHERE 
  record_date BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';

/* 6 - Índice de Gastos com Salários (Salary Expense Ratio) */
/* KPI: Salary Expense Ratio = (Total de Gastos com Salários / Receita Total) * 100 */
/* Esse KPI é essencial para entender a proporção de receita destinada a salários. */
/* A query SQL pressupõe que há tabelas payroll (folha de pagamento) e financials (dados financeiros) com um campo comum period (período), permitindo correlacionar gastos com receita. */
SELECT 
  (SUM(salaries) / SUM(revenue)) * 100 AS salary_expense_ratio
FROM 
  payroll, financials
WHERE 
  payroll.period = financials.period;
  
/* 7 - Identificar os funcionários que estão prontos para serem promovidos */
/* 
Em uma grande organização, os gerentes de RH geralmente enfrentam o desafio de identificar os funcionários que estão prontos para serem promovidos. 
Não se trata apenas de analisar a pontuação de desempenho mais recente. 
Trata-se de considerar toda a jornada do funcionário dentro da empresa. Os fatores podem incluir:
	- Alto desempenho consistente ao longo de vários anos.
	- Permanência na empresa (por exemplo, funcionários que estão na empresa há mais de 3 anos).
	- Conclusão de programas específicos de treinamento ou certificação.
Abaixo está uma consulta SQL hipotética que poderia fornecer os insights de que você precisa. Ela identifica os funcionários que:
	- Estão na empresa desde pelo menos 2020.
	- Concluíram um "Programa de Liderança Avançada".
	- Mantiveram uma pontuação média de desempenho acima de 4,5 (em uma escala de 1 a 5) por vários anos.
O resultado? Uma lista selecionada de funcionários, classificada por seu desempenho consistente, pronta para possíveis promoções internas.
*/
SELECT 
	e.employee_name, 
	e.department, 
	AVG(r.performance_score) as avg_score, 
	e.join_date, 
	t.training_completed
FROM employees e
	JOIN annual_reviews r ON e.employee_id = r.employee_id
	JOIN training_programs t ON e.employee_id = t.employee_id
WHERE e.join_date <= '2020-01-01'
	AND t.training_completed = 'Advanced Leadership Program'
GROUP BY e.employee_name, e.department, e.join_date, t.training_completed
HAVING AVG(r.performance_score) > 4.5
ORDER BY avg_score DESC;
