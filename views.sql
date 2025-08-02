-- Criação da view otimizada para inserção
-- Função corrigida para inserção simplificada
CREATE OR REPLACE VIEW vw_inserir_relatorio AS
SELECT 
    p.id AS id_pesquisador,
    p.nome AS nome_pesquisador,
    pr.escopo AS escopo_programa,
    v.tipo AS tipo_vulnerabilidade,
    '' AS descricao  -- Campo padrão para inserção
FROM 
    pesquisador p
CROSS JOIN 
    programa pr
CROSS JOIN 
    vulnerabilidade v
WHERE 1=0;  -- Garante view vazia para inserção

-- 2. Trigger para tratamento da inserção
CREATE OR REPLACE FUNCTION fn_trg_inserir_relatorio()
RETURNS TRIGGER AS $$
DECLARE
    v_programa_id INTEGER;
    v_vulnerabilidade_id INTEGER;
BEGIN
    -- Validar e obter ID do programa
    SELECT id INTO v_programa_id FROM programa WHERE escopo = NEW.escopo_programa;
    IF v_programa_id IS NULL THEN
        RAISE EXCEPTION 'Programa não encontrado com escopo: %', NEW.escopo_programa;
    END IF;
    
    -- Validar e obter ID da vulnerabilidade
    SELECT id INTO v_vulnerabilidade_id FROM vulnerabilidade WHERE tipo = NEW.tipo_vulnerabilidade;
    IF v_vulnerabilidade_id IS NULL THEN
        RAISE EXCEPTION 'Tipo de vulnerabilidade não encontrado: %', NEW.tipo_vulnerabilidade;
    END IF;
    
    -- Inserir o relatório
    INSERT INTO relatorio (id_pesquisador, id_programa, id_vulnerabilidade, descricao, status)
    VALUES (NEW.id_pesquisador, v_programa_id, v_vulnerabilidade_id, NEW.descricao, 'pendente');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Vincular trigger à view
CREATE TRIGGER trg_inserir_relatorio
INSTEAD OF INSERT ON vw_inserir_relatorio
FOR EACH ROW EXECUTE FUNCTION fn_trg_inserir_relatorio();


--Propósito
--Permitir a inserção de novos relatórios usando:
--ID do pesquisador (obrigatório)
--Escopo do programa (texto descritivo)
--Tipo de vulnerabilidade (nome)
--Descrição do problema

select * from vw_inserir_relatorio 
-- Inserção de exemplo
INSERT INTO vw_inserir_relatorio 
(id_pesquisador, escopo_programa, tipo_vulnerabilidade, descricao)
VALUES (
    1, 
    'Aplicativo mobile Android/iOS, API pública', 
    'SQL Injection', 
    'Vulnerabilidade encontrada no endpoint /api/users permitindo SQLi'
);



CREATE OR REPLACE VIEW vw_dashboard_empresa AS
SELECT 
    e.id AS empresa_id,
    e.nome AS empresa,
    COUNT(DISTINCT pr.id) AS programas_ativos,
    COUNT(DISTINCT r.id) AS relatorios_recebidos,
    COUNT(DISTINCT CASE WHEN r.status = 'valido' THEN r.id END) AS vulnerabilidades_validas,
    COUNT(DISTINCT rec.id) AS recompensas_pagas,
    COALESCE(SUM(rec.valor), 0) AS total_recompensado,
    MAX(rec.data_pagamento) AS ultimo_pagamento,
    STRING_AGG(DISTINCT v.tipo, ', ' ORDER BY v.tipo) AS tipos_vulnerabilidades
FROM 
    empresa e
LEFT JOIN 
    programa pr ON e.id = pr.id_empresa
LEFT JOIN 
    relatorio r ON pr.id = r.id_programa
LEFT JOIN 
    recompensa rec ON r.id = rec.id_relatorio
LEFT JOIN 
    vulnerabilidade v ON r.id_vulnerabilidade = v.id
GROUP BY 
    e.id, e.nome;

-- Justificativa semântica:
-- Esta visão consolida todos os KPIs relevantes para que empresas possam:
-- 1. Acompanhar o desempenho de seus programas de bug bounty
-- 2. Monitorar o volume e tipos de vulnerabilidades encontradas
-- 3. Controlar os custos com recompensas
-- 4. Identificar tendências de segurança
-- É essencial para a tomada de decisão estratégica das empresas participantes


CREATE OR REPLACE VIEW vw_performance_pesquisadores AS
SELECT 
    p.id,
    p.nome,
    p.email,
    p.reputacao_pontos,
    COUNT(DISTINCT r.id) AS total_relatorios,
    COUNT(DISTINCT CASE WHEN r.status = 'valido' THEN r.id END) AS relatorios_validos,
    COUNT(DISTINCT rec.id) AS recompensas_ganhas,
    COALESCE(SUM(rec.valor), 0) AS total_recompensado,
    ROUND(COUNT(DISTINCT CASE WHEN r.status = 'valido' THEN r.id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT r.id), 0), 2) AS taxa_sucesso,
    MIN(r.data_submissao) AS primeira_submissao,
    MAX(r.data_submissao) AS ultima_submissao,
    STRING_AGG(DISTINCT v.tipo, ', ' ORDER BY v.tipo) AS especializacoes,
    (SELECT e.nome 
     FROM empresa e
     JOIN programa pr ON e.id = pr.id_empresa
     JOIN relatorio r2 ON pr.id = r2.id_programa
     WHERE r2.id_pesquisador = p.id
     GROUP BY e.nome
     ORDER BY COUNT(*) DESC
     LIMIT 1) AS empresa_frequente
FROM 
    pesquisador p
LEFT JOIN 
    relatorio r ON p.id = r.id_pesquisador
LEFT JOIN 
    recompensa rec ON r.id = rec.id_relatorio
LEFT JOIN 
    vulnerabilidade v ON r.id_vulnerabilidade = v.id
GROUP BY 
    p.id, p.nome, p.email, p.reputacao_pontos
ORDER BY 
    total_recompensado DESC;

-- Justificativa semântica:
-- Esta visão fornece uma análise completa do desempenho dos pesquisadores:
-- 1. Permite ranquear os pesquisadores mais eficientes
-- 2. Identifica especializações por tipo de vulnerabilidade
-- 3. Calcula métricas de qualidade (taxa de sucesso)
-- 4. Oferece dados para o sistema de reputação
-- 5. É fundamental para a equipe de triagem priorizar relatórios
-- 6. Ajuda empresas a identificar pesquisadores especializados




