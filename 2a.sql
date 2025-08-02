-- Pesquisadores com reputação entre 500 e 1000 pontos que reportaram vulnerabilidades do tipo SQL Injection ou XSS
-- 1. Consulta com operadores básicos de filtro
SELECT p.nome, p.reputacao_pontos, v.tipo
FROM pesquisador p
JOIN relatorio r ON p.id = r.id_pesquisador
JOIN vulnerabilidade v ON r.id_vulnerabilidade = v.id
WHERE p.reputacao_pontos BETWEEN 500 AND 1000
AND v.tipo IN ('SQL Injection', 'XSS')
ORDER BY p.reputacao_pontos DESC;


-- 2. Consultas com INNER JOIN
-- 2.1 Relatórios válidos com detalhes completos

SELECT r.id, p.nome AS pesquisador, e.nome AS empresa, 
       v.tipo AS vulnerabilidade, r.descricao, r.data_submissao
FROM relatorio r
INNER JOIN pesquisador p ON r.id_pesquisador = p.id
INNER JOIN programa pr ON r.id_programa = pr.id
INNER JOIN empresa e ON pr.id_empresa = e.id
INNER JOIN vulnerabilidade v ON r.id_vulnerabilidade = v.id
WHERE r.status = 'valido'
ORDER BY r.data_submissao DESC;


--- 2.2 Recompensas pagas com informações do pesquisador e programa
-- rever isso aq
SELECT rec.id, ps.nome AS pesquisador, emp.nome AS empresa, 
       rec.valor, rec.data_pagamento
FROM recompensa rec
INNER JOIN pesquisador ps ON rec.id_pesquisador = ps.id
INNER JOIN programa pr ON rec.id_programa = pr.id
INNER JOIN empresa emp ON pr.id_empresa = emp.id
WHERE rec.status_pagamento = 'pago'
ORDER BY rec.valor DESC;



-- 2.3 Self-join: Pesquisadores com reputação similar


SELECT p1.nome AS pesquisador1, p2.nome AS pesquisador2, 
       p1.reputacao_pontos
FROM pesquisador p1
INNER JOIN pesquisador p2 ON p1.reputacao_pontos BETWEEN p2.reputacao_pontos - 100 AND p2.reputacao_pontos + 100
WHERE p1.id < p2.id  -- Evita duplicatas e comparação consigo mesmo
ORDER BY p1.reputacao_pontos DESC;


-- 3. Consulta com OUTER JOIN

-- Todos os programas, mostrando recompensas mesmo que não tenham nenhuma
SELECT pr.id AS programa_id, pr.escopo, 
       COUNT(rec.id) AS total_recompensas,
       COALESCE(SUM(rec.valor), 0) AS valor_total
FROM programa pr
LEFT OUTER JOIN recompensa rec ON pr.id = rec.id_programa
GROUP BY pr.id
ORDER BY valor_total DESC;


-- 4. Consultas com GROUP BY
-- 4.1 Total de recompensas por pesquisador

SELECT p.nome, COUNT(r.id) AS total_recompensas, 
       SUM(rec.valor) AS valor_total_recebido
FROM pesquisador p
LEFT JOIN recompensa rec ON p.id = rec.id_pesquisador
LEFT JOIN relatorio r ON rec.id_relatorio = r.id
GROUP BY p.id
HAVING COUNT(r.id) > 0  -- Apenas pesquisadores que receberam recompensas
ORDER BY valor_total_recebido DESC;

-- 4.2 Tipos de vulnerabilidade mais comuns por empresa

SELECT e.nome AS empresa, v.tipo AS vulnerabilidade, 
       COUNT(*) AS total_ocorrencias
FROM empresa e
JOIN programa pr ON e.id = pr.id_empresa
JOIN relatorio r ON pr.id = r.id_programa
JOIN vulnerabilidade v ON r.id_vulnerabilidade = v.id
GROUP BY e.nome, v.tipo
HAVING COUNT(*) > 1  -- Mostra apenas vulnerabilidades recorrentes
ORDER BY e.nome, total_ocorrencias DESC;


-- 5.Status de Relatórios e Recompensas
-- Visão unificada do status de relatórios e pagamentos / status do relatorios
-- (mudar)

SELECT 
    r.id,
    'Relatório' AS tipo_objeto,
    r.status AS status,
    r.data_submissao AS data_referencia
FROM 
    relatorio r

UNION

SELECT 
    rec.id,
    'Recompensa' AS tipo_objeto,
    rec.status_pagamento AS status,
    rec.data_pagamento AS data_referencia
FROM 
    recompensa rec

ORDER BY data_referencia DESC NULLS LAST;

-- 6. Consultas com subqueries
-- 6.1 Pesquisadores que encontraram vulnerabilidades críticas (acima da média de recompensas)

SELECT p.nome, v.tipo, rec.valor
FROM pesquisador p
JOIN recompensa rec ON p.id = rec.id_pesquisador
JOIN relatorio r ON rec.id_relatorio = r.id
JOIN vulnerabilidade v ON r.id_vulnerabilidade = v.id
WHERE rec.valor > (
    SELECT AVG(valor) 
    FROM recompensa
)
ORDER BY rec.valor DESC;

-- 6.2 Programas com desempenho abaixo da média em recompensas pagas

SELECT pr.id, e.nome AS empresa, pr.escopo, 
       pr.valor_total_recompensas
FROM programa pr
JOIN empresa e ON pr.id_empresa = e.id
WHERE pr.valor_total_recompensas < (
    SELECT AVG(valor_total_recompensas) 
    FROM programa
    WHERE valor_total_recompensas > 0
)
ORDER BY pr.valor_total_recompensas;
