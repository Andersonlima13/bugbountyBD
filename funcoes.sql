-- 1. Função com Operador de Agregação (COUNT)

CREATE OR REPLACE FUNCTION contar_vulnerabilidades_validas(p_pesquisador_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM relatorio
    WHERE id_pesquisador = p_pesquisador_id
    AND status = 'valido';
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

--Uso: SELECT contar_vulnerabilidades_validas(123);
--Justificativa: Permite verificar quantas vulnerabilidades
--válidas um pesquisador reportou, útil para calcular reputação ou bonificações


-- 2. Função com Tratamento de Exceção

CREATE OR REPLACE FUNCTION calcular_recompensa_media_por_tipo(p_tipo_vulnerabilidade VARCHAR(50))
RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_media NUMERIC(10,2);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM vulnerabilidade WHERE tipo = p_tipo_vulnerabilidade) THEN
        RAISE EXCEPTION 'Tipo de vulnerabilidade não encontrado: %', p_tipo_vulnerabilidade;
    END IF;
    
    SELECT AVG(rec.valor) INTO v_media
    FROM recompensa rec
    JOIN relatorio r ON rec.id_relatorio = r.id
    JOIN vulnerabilidade v ON r.id_vulnerabilidade = v.id
    WHERE v.tipo = p_tipo_vulnerabilidade
    AND rec.status_pagamento = 'pago';
    
    RETURN COALESCE(v_media, 0);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao calcular média para %: %', p_tipo_vulnerabilidade, SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--Uso: SELECT calcular_recompensa_media_por_tipo('SQL Injection');
--Justificativa: Calcula o valor médio pago por tipo de vulnerabilidade, 
--essencial para pesquisadores entenderem o mercado e empresas ajustarem suas tabelas de recompensas.



--3. Função para Atualização de Reputação

CREATE OR REPLACE FUNCTION atualizar_reputacao_pesquisador(p_pesquisador_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_pontos INTEGER;
    v_recompensas NUMERIC(10,2);
BEGIN
    -- Calcula pontos baseados no total recebido em recompensas
    SELECT COALESCE(SUM(valor), 0) INTO v_recompensas
    FROM recompensa
    WHERE id_pesquisador = p_pesquisador_id
    AND status_pagamento = 'pago';
    
    -- Fórmula: 1 ponto para cada $100 recebido, limitado a 5000 pontos
    v_pontos := LEAST((v_recompensas / 100)::INTEGER, 5000);
    
    UPDATE pesquisador
    SET reputacao_pontos = v_pontos
    WHERE id = p_pesquisador_id;
    
    RETURN v_pontos;
END;
$$ LANGUAGE plpgsql;


--Uso: SELECT atualizar_reputacao_pesquisador(123);
--Justificativa: Automatiza a atualização da reputação do 
--pesquisador baseado no histórico de recompensas, incentivando participação contínua.

























