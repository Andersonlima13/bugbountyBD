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




