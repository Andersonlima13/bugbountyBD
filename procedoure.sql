CREATE OR REPLACE PROCEDURE aprovar_relatorio_basico(p_relatorio_id INTEGER)
AS $$
BEGIN
    -- Aprova o relatório e cria recompensa padrão de $1000
    UPDATE relatorio
    SET status = 'valido'
    WHERE id = p_relatorio_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Relatório ID % não encontrado', p_relatorio_id;
    END IF;
    
    INSERT INTO recompensa (
        id_relatorio,
        id_pesquisador,
        id_programa,
        valor,
        status_pagamento
    )
    SELECT 
        r.id,
        r.id_pesquisador,
        r.id_programa,
        1000.00, -- Valor fixo
        'pendente'
    FROM relatorio r
    WHERE r.id = p_relatorio_id;
END;
$$ LANGUAGE plpgsql;


CALL aprovar_relatorio_basico(457);



-- Esta procedure realiza uma operação fundamental no sistema de Bug Bounty: 
--aprova um relatório de vulnerabilidade e associa uma recompensa padrão. 
--Muda o status do relatório para 'valido' (indicando que a vulnerabilidade foi confirmada)








