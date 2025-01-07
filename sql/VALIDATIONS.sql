-- Verificar dados na tabela histCasosTrabalhados
-- Descrição: Exibe todos os registros presentes na tabela para validação geral.
SELECT *
FROM histCasosTrabalhados;

-- Verificar dados duplicados na tabela histCasosTrabalhados
-- Descrição: Identifica registros duplicados com base em todas as colunas relevantes.
SELECT 
    Id_Caso, -- Coluna que identifica o caso
    País,
    Canal_Entrada,
    Status,
    Resolução,
    Motivo_Chamador,
    NomeAgen,
    NomeSupe,
    Data_Hora_Criação,
    Data_Hora_Atualização,
    Data_Hora_Fechamento,
    COUNT(*) AS TotalDuplicados
FROM histCasosTrabalhados
GROUP BY 
    Id_Caso, 
    País,
    Canal_Entrada,
    Status,
    Resolução,
    Motivo_Chamador,
    NomeAgen,
    NomeSupe,
    Data_Hora_Criação,
    Data_Hora_Atualização,
    Data_Hora_Fechamento
HAVING COUNT(*) > 1;

-- Verificar dados nulos na tabela histCasosTrabalhados
-- Descrição: Conta a quantidade de valores nulos em cada coluna.
SELECT
    SUM(CASE WHEN Id_Caso IS NULL THEN 1 ELSE 0 END) AS Nulos_Id_Caso,
    SUM(CASE WHEN País IS NULL THEN 1 ELSE 0 END) AS Nulos_Pais,
    SUM(CASE WHEN Canal_Entrada IS NULL THEN 1 ELSE 0 END) AS Nulos_Canal_Entrada,
    SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS Nulos_Status,
    SUM(CASE WHEN Resolução IS NULL THEN 1 ELSE 0 END) AS Nulos_Resolucao,
    SUM(CASE WHEN Motivo_Chamador IS NULL THEN 1 ELSE 0 END) AS Nulos_Motivo_Chamador,
    SUM(CASE WHEN NomeAgen IS NULL THEN 1 ELSE 0 END) AS Nulos_NomeAgen,
    SUM(CASE WHEN NomeSupe IS NULL THEN 1 ELSE 0 END) AS Nulos_NomeSupe,
    SUM(CASE WHEN Data_Hora_Criação IS NULL THEN 1 ELSE 0 END) AS Nulos_Data_Hora_Criacao,
    SUM(CASE WHEN Data_Hora_Atualização IS NULL THEN 1 ELSE 0 END) AS Nulos_Data_Hora_Atualizacao,
    SUM(CASE WHEN Data_Hora_Fechamento IS NULL THEN 1 ELSE 0 END) AS Nulos_Data_Hora_Fechamento
FROM histCasosTrabalhados;

-- Verificar duplicidade e nulidade na tabela dimCalendario
-- Descrição: Identifica registros duplicados e conta valores nulos nas colunas principais.
SELECT 
    IdCalendario,
    Data_Hora_Criação,
    Ano,
    Mes,
    Dia,
    COUNT(*) AS TotalDuplicados
FROM dimCalendario
GROUP BY
    IdCalendario,
    Data_Hora_Criação,
    Ano,
    Mes,
    Dia
HAVING COUNT(*) > 1;

SELECT
    SUM(CASE WHEN IdCalendario IS NULL THEN 1 ELSE 0 END) AS Nulos_IdCalendario,
    SUM(CASE WHEN Data_Hora_Criação IS NULL THEN 1 ELSE 0 END) AS Nulos_Data_Hora_Criacao,
    SUM(CASE WHEN Ano IS NULL THEN 1 ELSE 0 END) AS Nulos_Ano,
    SUM(CASE WHEN Mes IS NULL THEN 1 ELSE 0 END) AS Nulos_Mes,
    SUM(CASE WHEN Dia IS NULL THEN 1 ELSE 0 END) AS Nulos_Dia
FROM dimCalendario;

-- Validar duplicidade e nulidade na tabela dimFuncionario
-- Descrição: Realiza verificações semelhantes na dimensão de funcionários.
SELECT 
    IdFuncionario,  
    NomeAgen,  
    COUNT(*) AS TotalDuplicados
FROM dimFuncionario
GROUP BY 
    IdFuncionario,  
    NomeAgen   
HAVING COUNT(*) > 1;

SELECT 
    SUM(CASE WHEN IdFuncionario IS NULL THEN 1 ELSE 0 END) AS Nulos_IdFuncionario,
    SUM(CASE WHEN NomeAgen IS NULL THEN 1 ELSE 0 END) AS Nulos_NomeAgen
FROM dimFuncionario;

-- Validar duplicidade e nulidade em outras dimensões
-- Descrição: Aplica o mesmo processo para as tabelas dimSupervisor, dimMotiChamador, dimStatus, dimCanalEntrada e dimPais, verificando duplicidade e nulidade.