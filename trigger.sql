-- 1. Trigger para Atualização Automática de Reputação


CREATE OR REPLACE FUNCTION fn_atualizar_reputacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza a reputação do pesquisador quando uma recompensa é paga
    IF NEW.status_pagamento = 'pago' AND OLD.status_pagamento != 'pago' THEN
        UPDATE pesquisador
        SET reputacao_pontos = reputacao_pontos + (NEW.valor / 100)::INTEGER
        WHERE id = NEW.id_pesquisador;
        
        RAISE NOTICE 'Reputação do pesquisador % atualizada com +% pontos', 
            NEW.id_pesquisador, (NEW.valor / 100)::INTEGER;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_reputacao
AFTER UPDATE ON recompensa
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_reputacao();

--Atualiza automaticamente a pontuação de reputação do pesquisador quando uma recompensa é marcada como "paga"
--Calcula pontos baseados no valor da recompensa (1 ponto para cada $100)

-- 2. Trigger para Validação de Relatórios Duplicados


CREATE OR REPLACE FUNCTION fn_validar_relatorio_duplicado()
RETURNS TRIGGER AS $$
DECLARE
    v_relatorio_similar INTEGER;
BEGIN
    -- Verifica se já existe um relatório similar (mesmo programa e mesma vulnerabilidade)
    SELECT id INTO v_relatorio_similar
    FROM relatorio
    WHERE id_programa = NEW.id_programa
    AND id_vulnerabilidade = NEW.id_vulnerabilidade
    AND descricao ILIKE '%' || substring(NEW.descricao from 1 for 20) || '%'
    AND id != COALESCE(NEW.id, -1)  -- Ignora o próprio registro em caso de update
    LIMIT 1;
    
    IF v_relatorio_similar IS NOT NULL THEN
        RAISE EXCEPTION 'Relatório duplicado/similar encontrado (ID: %). Verifique o relatório existente antes de submeter.', 
            v_relatorio_similar;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_relatorio_duplicado
BEFORE INSERT OR UPDATE ON relatorio
FOR EACH ROW
EXECUTE FUNCTION fn_validar_relatorio_duplicado();

--Previne submissão de relatórios duplicados ou muito similares

--Compara programa, tipo de vulnerabilidade e parte inicial da descrição
--Evento: BEFORE INSERT OR UPDATE na tabela relatorio
--Condição: Executa para todos os novos relatórios e atualizações


