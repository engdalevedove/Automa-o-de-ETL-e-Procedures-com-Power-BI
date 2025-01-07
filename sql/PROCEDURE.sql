-- Procedure: AtualizarDimensoesEFato
-- Descrição: Atualiza as tabelas de dimensões e a tabela fato, consolidando dados da tabela histCasosTrabalhados.
CREATE PROCEDURE AtualizarDimensoesEFato
AS
BEGIN
    BEGIN TRANSACTION;

    -- Atualização de Dimensões
    
    -- Atualizar dimCalendario
    -- Descrição: Insere novas datas na dimensão de calendário.
    MERGE INTO dimCalendario AS Target
    USING (
       SELECT DISTINCT 
          CAST([Data_Hora_Criação] AS DATETIME) AS DataCriacao 
       FROM histCasosTrabalhados
    ) AS Source
    ON  Target.[Data_Hora_Criação] = Source.DataCriacao
    WHEN NOT MATCHED THEN
        INSERT ([Data_Hora_Criação]) 
        VALUES (Source.DataCriacao);

    -- Atualizar dimFuncionario
    -- Descrição: Insere novos agentes na dimensão de funcionários.
    MERGE INTO dimFuncionario AS Target
    USING (SELECT DISTINCT NomeAgen FROM histCasosTrabalhados) AS Source
    ON Target.NomeAgen = Source.NomeAgen
    WHEN NOT MATCHED THEN
        INSERT (NomeAgen) VALUES (Source.NomeAgen);

    -- Atualizar dimSupervisor
    -- Descrição: Insere novos supervisores na dimensão.
    MERGE INTO dimSupervisor AS Target
    USING (SELECT DISTINCT NomeSupe FROM histCasosTrabalhados) AS Source
    ON Target.NomeSupe = Source.NomeSupe
    WHEN NOT MATCHED THEN
        INSERT (NomeSupe) VALUES (Source.NomeSupe);

    -- Atualizar dimMotiChamador
    -- Descrição: Insere novos motivos dos chamadores na dimensão.
    MERGE INTO dimMotiChamador AS Target
    USING (SELECT DISTINCT Motivo_Chamador FROM histCasosTrabalhados) AS Source
    ON Target.Motivo_Chamador = Source.Motivo_Chamador
    WHEN NOT MATCHED THEN
        INSERT (Motivo_Chamador) VALUES (Source.Motivo_Chamador);

    -- Atualizar dimStatus
    -- Descrição: Insere novos status na dimensão.
    MERGE INTO dimStatus AS Target
    USING (SELECT DISTINCT Status FROM histCasosTrabalhados) AS Source
    ON Target.Status = Source.Status
    WHEN NOT MATCHED THEN
        INSERT (Status) VALUES (Source.Status);

    -- Atualizar dimCanalEntrada
    -- Descrição: Insere novos canais de entrada na dimensão.
    MERGE INTO dimCanalEntrada AS Target
    USING (SELECT DISTINCT Canal_Entrada FROM histCasosTrabalhados) AS Source
    ON Target.Canal_Entrada = Source.Canal_Entrada
    WHEN NOT MATCHED THEN
        INSERT (Canal_Entrada) VALUES (Source.Canal_Entrada);

    -- Atualizar dimPais
    -- Descrição: Insere novos países na dimensão.
    MERGE INTO dimPais AS Target
    USING (SELECT DISTINCT País FROM histCasosTrabalhados) AS Source
    ON Target.País = Source.País
    WHEN NOT MATCHED THEN
        INSERT (País) VALUES (Source.País);

    -- Atualização da Tabela Fato
    -- Descrição: Consolida dados na tabela fato com cálculos de resolução, casos fechados, abertos e tempos médios.
    WITH CTE AS (
        SELECT 
            cal.IdCalendario,
            func.IdFuncionario,
            sup.IdSupervisor,
            moti.IdMotivo,
            stat.IdStatus,
            canal.IdCanalEntrada,
            pais.IdPais,
            CASE 
                WHEN SUM(CASE WHEN hist.Resolução IN ('Yes', 'No') THEN 1 ELSE 0 END) = 0 THEN 0
                ELSE 100.0 * SUM(CASE WHEN hist.Resolução = 'Yes' THEN 1 ELSE 0 END) / 
                     NULLIF(SUM(CASE WHEN hist.Resolução IN ('Yes', 'No', 'NULL') THEN 1 ELSE 0 END), 0)
            END AS PercentualResolucao,
            COUNT(CASE WHEN hist.Status = 'Done' THEN 1 END) AS TotalCasosFechados,
            COUNT(CASE WHEN hist.Status != 'Done' THEN 1 END) AS TotalCasosAbertos,
            AVG(DATEDIFF(HOUR, hist.Data_Hora_Criação, ISNULL(hist.Data_Hora_Atualização, hist.Data_Hora_Criação))) AS TempoMedioAtualizacao,
            AVG(
                COALESCE(
                    CASE
                        WHEN hist.Data_Hora_Fechamento >= hist.Data_Hora_Criação THEN
                            DATEDIFF(HOUR, hist.Data_Hora_Criação, COALESCE(hist.Data_Hora_Fechamento, hist.Data_Hora_Criação))
                        ELSE
                            NULL
                    END,
                    0
                )
            ) AS TempoMedioFechamento
        FROM histCasosTrabalhados hist
        JOIN dimCalendario cal ON cal.Data_Hora_Criação  = CAST(hist.Data_Hora_Criação AS DATETIME)
        JOIN dimFuncionario func ON func.NomeAgen = hist.NomeAgen
        JOIN dimSupervisor sup ON sup.NomeSupe = hist.NomeSupe
        JOIN dimMotiChamador moti ON moti.Motivo_Chamador = hist.Motivo_Chamador
        JOIN dimStatus stat ON stat.Status = hist.Status
        JOIN dimCanalEntrada canal ON canal.Canal_Entrada = hist.Canal_Entrada
        JOIN dimPais pais ON pais.País = hist.País
        GROUP BY 
            cal.IdCalendario,
            func.IdFuncionario,
            sup.IdSupervisor,
            moti.IdMotivo,
            stat.IdStatus,
            canal.IdCanalEntrada,
            pais.IdPais
    )
    INSERT INTO fatoCasos (
        IdCalendario,
        IdFuncionario,
        IdSupervisor,
        IdMotivo,
        IdStatus,
        IdCanalEntrada,
        IdPais,
        PercentualResolucao,
        TotalCasosFechados,
        TotalCasosAbertos,
        TempoMedioAtualizacao,
        TempoMedioFechamento
    )
    SELECT 
        IdCalendario,
        IdFuncionario,
        IdSupervisor,
        IdMotivo,
        IdStatus,
        IdCanalEntrada,
        IdPais,
        PercentualResolucao,
        TotalCasosFechados,
        TotalCasosAbertos,
        TempoMedioAtualizacao,
        TempoMedioFechamento
    FROM CTE
    WHERE NOT EXISTS (
        SELECT 1 
        FROM fatoCasos fc
        WHERE 
            fc.IdCalendario = CTE.IdCalendario AND
            fc.IdFuncionario = CTE.IdFuncionario AND
            fc.IdSupervisor = CTE.IdSupervisor AND
            fc.IdMotivo = CTE.IdMotivo AND
            fc.IdStatus = CTE.IdStatus AND
            fc.IdCanalEntrada = CTE.IdCanalEntrada AND
            fc.IdPais = CTE.IdPais
    );

    COMMIT TRANSACTION;
END;



