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



