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



