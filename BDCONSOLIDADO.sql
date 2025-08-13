-- Tabela de empresas
CREATE TABLE empresa (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de programas - agora com valor_total_recompensas
CREATE TABLE programa (
    id SERIAL PRIMARY KEY,
    id_empresa INTEGER NOT NULL,
    data_inicio DATE NOT NULL,
    escopo TEXT NOT NULL,
    valor_total_recompensas INTEGER DEFAULT 0, -- Novo campo acumulativo
    CONSTRAINT fk_empresa 
        FOREIGN KEY (id_empresa) REFERENCES empresa(id)
        ON DELETE CASCADE
);

-- Tabela de pesquisadores
CREATE TABLE pesquisador (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    reputacao_pontos INTEGER DEFAULT 0
);

-- Tabela de vulnerabilidades
CREATE TABLE vulnerabilidade (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    descricao TEXT NOT NULL,
    impacto TEXT NOT NULL
);

-- Tabela de relatórios
CREATE TABLE relatorio (
    id SERIAL PRIMARY KEY,
    id_pesquisador INTEGER NOT NULL,
    id_programa INTEGER NOT NULL,
    id_vulnerabilidade INTEGER NOT NULL,
    descricao TEXT NOT NULL,
    data_submissao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pendente',
    CONSTRAINT fk_pesquisador 
        FOREIGN KEY (id_pesquisador) REFERENCES pesquisador(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_programa 
        FOREIGN KEY (id_programa) REFERENCES programa(id),
    CONSTRAINT fk_vulnerabilidade 
        FOREIGN KEY (id_vulnerabilidade) REFERENCES vulnerabilidade(id)
);

-- Tabela de recompensas com trigger para atualizar o valor_total_recompensas
CREATE TABLE recompensa (
    id SERIAL PRIMARY KEY,
    id_relatorio INTEGER NOT NULL UNIQUE,
    id_pesquisador INTEGER NOT NULL,
    id_programa INTEGER NOT NULL, -- Adicionado para facilitar o trigger
    valor INTEGER NOT NULL, -- Alterado para INT conforme solicitado
    status_pagamento VARCHAR(20) DEFAULT 'pendente',
    data_pagamento DATE,
    CONSTRAINT fk_relatorio 
        FOREIGN KEY (id_relatorio) REFERENCES relatorio(id),
    CONSTRAINT fk_pesquisador 
        FOREIGN KEY (id_pesquisador) REFERENCES pesquisador(id),
    CONSTRAINT fk_programa
        FOREIGN KEY (id_programa) REFERENCES programa(id)
);




------------------------------------------------------------------------------------


-- Inserts 

-- Inserindo empresas
INSERT INTO empresa (nome) VALUES 
('TechSecure Inc.'),

('DataProtect Ltda.'),
('CloudSafe Solutions');

-- Inserindo programas (com valor_total_recompensas inicial 0)
INSERT INTO programa (id_empresa, data_inicio, escopo) VALUES
(1, '2023-01-15', 'Aplicativo mobile Android/iOS, API pública'),
(1, '2023-03-10', 'Infraestrutura em nuvem'),
(2, '2023-02-20', 'Portal web e API de pagamentos'),
(3, '2023-04-05', 'Toda a plataforma SaaS');

-- Inserindo pesquisadores
INSERT INTO pesquisador (nome, email, reputacao_pontos) VALUES
('Ana Silva', 'ana.silva@security.com', 850),
('Carlos Mendes', 'carlos.m@whitehat.com', 1200),
('Bia Hack', 'bia.hack@bugfinder.org', 430),
('Rafael White', 'rafa.white@hacker.net', 1500);

-- Inserindo vulnerabilidades
INSERT INTO vulnerabilidade (tipo, descricao, impacto) VALUES
('SQL Injection', 'Injeção de código SQL malicioso', 'Acesso não autorizado a banco de dados'),
('XSS', 'Cross-site Scripting', 'Execução de scripts maliciosos no navegador de usuários'),
('Quebra de Autenticação', 'Falha no mecanismo de login', 'Acesso não autorizado a contas de usuários'),
('Exposição de Dados Sensíveis', 'Dados expostos sem proteção adequada', 'Vazamento de informações confidenciais');

-- Inserindo relatórios
INSERT INTO relatorio (id_pesquisador, id_programa, id_vulnerabilidade, descricao, status) VALUES
(1, 1, 1, 'Encontrada vulnerabilidade SQLi no endpoint /api/v1/users', 'valido'),
(2, 1, 2, 'XSS refletido no parâmetro "search" do aplicativo mobile', 'valido'),
(3, 2, 3, 'Autenticação bypass via modificação de cookie', 'pendente'),
(1, 3, 4, 'Chaves API expostas no código JavaScript front-end', 'valido'),
(4, 4, 1, 'SQL Injection na página de administração', 'valido'),
(2, 3, 2, 'XSS armazenado no sistema de comentários', 'invalido');

-- Inserindo recompensas (que atualizarão automaticamente valor_total_recompensas)
INSERT INTO recompensa (id_relatorio, id_pesquisador, id_programa, valor, status_pagamento, data_pagamento) VALUES
(1, 1, 1, 5000, 'pago', '2023-02-10'),
(2, 2, 1, 2000, 'pago', '2023-02-15'),
(4, 1, 3, 7500, 'processando', NULL),
(5, 4, 4, 15000, 'pago', '2023-05-20');




---------------------------------------------------------------------------------------------------------------------------------------------------

-- 1 view , permite insercao de uma vulnerabilidade
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




---------------------------------------------------------------------------------------------------------------------------------------------


-- 1. Índice Composto para Consultas de Relatórios Válidos
--Justificativa: Otimiza a consulta 2.1 que filtra por status 'valido' e faz join com vulnerabilidade. 
--O índice filtrado é especialmente eficiente pois só indexa os registros com status 'valido'.

CREATE INDEX idx_relatorio_status_vulnerabilidade ON relatorio(status, id_vulnerabilidade) 
WHERE status = 'valido';



-- 2. Índice para Recompensas Pagas e Valor

CREATE INDEX idx_recompensa_paga_valor ON recompensa(status_pagamento, valor DESC, id_programa, id_pesquisador) 
WHERE status_pagamento = 'pago';

--Justificativa: Melhora a consulta 2.2 que busca recompensas pagas ordenadas por valor e as consultas 6.1 que filtram por 
--valor acima da média. Inclui os campos de join para evitar acessos adicionais à tabela.


-- 3. Índice Composto para Pesquisadores e Reputação

CREATE INDEX idx_vulnerabilidade_tipo ON vulnerabilidade(tipo);

--Otimiza: Consultas 1, 2.1 e 4.2 (filtros por tipo de vulnerabilidade)
--Benefício: Acelera os JOINs e filtros IN() com tipos específicos





-----------------------------------------------------------------------------------------------------------------------------------------------------

Funções

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


-- 2. Função para Contar Relatórios por Pesquisador

CREATE OR REPLACE FUNCTION contar_relatorios_pesquisador(p_pesquisador_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM relatorio
    WHERE id_pesquisador = p_pesquisador_id;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;


--Uso: SELECT contar_relatorios_pesquisador(456);
--Finalidade: Conta quantos relatórios um pesquisador submeteu.


-- PROCEDURE 



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
-- alterar : valor nao deve ser padrao , e sim um valor associado a vulnerabilidade a qual o relatorio foi vinculada 



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

-- 2.  Função e Trigger para Notificação de Alteração de Escopo


-- Função para gerar a notificação de alteração de escopo
CREATE OR REPLACE FUNCTION fn_notificar_alteracao_escopo()
RETURNS TRIGGER AS $$
DECLARE
    v_nome_empresa VARCHAR(100);
BEGIN
    -- Obtém o nome da empresa dona do programa
    SELECT e.nome INTO v_nome_empresa
    FROM empresa e
    WHERE e.id = NEW.id_empresa;
    
    -- Exibe a mensagem com as informações da alteração
    RAISE NOTICE 'O escopo do programa % da empresa % foi alterado de "%" para "%"',
        NEW.id,
        v_nome_empresa,
        OLD.escopo,
        NEW.escopo;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que executa após atualização na tabela programa
CREATE TRIGGER trg_notificar_alteracao_escopo
AFTER UPDATE OF escopo ON programa
FOR EACH ROW
WHEN (OLD.escopo IS DISTINCT FROM NEW.escopo)
EXECUTE FUNCTION fn_notificar_alteracao_escopo();


- Atualização que disparará o trigger
UPDATE programa 
SET escopo = 'Novo escopo incluindo APIs REST' 
WHERE id = 1;

-- Saída esperada:
-- NOTICE:  O escopo do programa 1 da empresa TechSecure Inc. foi alterado de "Aplicativo mobile Android/iOS, API pública" para "Novo escopo incluindo APIs REST"







-- 3 . Trigger  para Notificação de Recompensas Pagas


CREATE OR REPLACE FUNCTION fn_notificar_marco_reputacao()
RETURNS TRIGGER AS $$
DECLARE
    v_marco INTEGER;
    v_email_pesquisador VARCHAR(100);
BEGIN
    -- Verifica se a reputação atingiu algum marco (1000, 2500, 5000 pontos)
    SELECT 
        CASE 
            WHEN NEW.reputacao_pontos >= 5000 THEN 5000
            WHEN NEW.reputacao_pontos >= 2500 THEN 2500
            WHEN NEW.reputacao_pontos >= 1000 THEN 1000
            ELSE NULL
        END INTO v_marco
    WHERE NEW.reputacao_pontos >= 1000
    AND (OLD.reputacao_pontos < 1000 
         OR (NEW.reputacao_pontos >= 2500 AND OLD.reputacao_pontos < 2500)
         OR (NEW.reputacao_pontos >= 5000 AND OLD.reputacao_pontos < 5000));
    
    -- Se atingiu um marco, "envia" notificação (simulado com RAISE NOTICE)
    IF v_marco IS NOT NULL THEN
        SELECT email INTO v_email_pesquisador FROM pesquisador WHERE id = NEW.id;
        
        RAISE NOTICE 'NOTIFICAÇÃO: Pesquisador % atingiu % pontos de reputação. Email enviado para: %', 
            NEW.nome, v_marco, v_email_pesquisador;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_verificar_marco_reputacao
AFTER UPDATE OF reputacao_pontos ON pesquisador
FOR EACH ROW
WHEN (NEW.reputacao_pontos >= 1000 AND NEW.reputacao_pontos > OLD.reputacao_pontos)
EXECUTE FUNCTION fn_notificar_marco_reputacao();





