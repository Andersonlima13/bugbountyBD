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

select * from empresa
select * from recompensa