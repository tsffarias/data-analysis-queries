/* 1- Taxa de Rotatividade (Turnover Rate) */
/* KPI: Turnover Rate = (Número de Desligamentos / Média de Funcionários) * 100 */

SELECT 
  (COUNT(employee_id) / AVG(total_employees)) * 100 AS turnover_rate
FROM 
  employee_departures, total_employees
WHERE 
  departure_date BETWEEN 'YYYY-MM-DD' AND 'YYYY-MM-DD';

/* 2 - Custo de Contratação (Cost Per Hire) */
/* KPI: Cost Per Hire = (Custo Total de Contratação / Número de Contratações) */

SELECT 
  SUM(cost) / COUNT(hire_id) AS cost_per_hire
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
