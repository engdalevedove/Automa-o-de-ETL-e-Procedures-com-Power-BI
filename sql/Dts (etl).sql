-- Importar dados do CSV para a tabela histCasosTrabalhados
-- Descrição: Realiza a carga inicial de dados a partir de um arquivo CSV.
BULK INSERT histCasosTrabalhados
FROM 'C:\Users\engda\Downloads\BaseCasos.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Atualização de valores nulos na tabela histCasosTrabalhados
-- Descrição: Substitui valores nulos nas colunas País e Motivo_Chamador por valores padrão.
UPDATE histCasosTrabalhados
SET País = 'N/D'
WHERE País IS NULL;

UPDATE histCasosTrabalhados
SET Motivo_Chamador = 'Não Definido'
WHERE Motivo_Chamador IS NULL;

-- Inserção de novos dados na tabela histCasosTrabalhados
-- Descrição: Adiciona novos registros com informações de casos trabalhados.
INSERT INTO histCasosTrabalhados (Id_Caso, Data_Hora_Criação, NomeAgen, NomeSupe, Motivo_Chamador, Status, Canal_Entrada, País)
VALUES (25551, '2025-01-04 10:00:00', 'Agente1', 'Supervisor1', 'Motivo1', 'Done', 'Canal1', 'BR');

INSERT INTO histCasosTrabalhados (Id_Caso, Data_Hora_Criação, NomeAgen, NomeSupe, Motivo_Chamador, Status, Canal_Entrada, País)
VALUES (25552, '2025-01-03 16:12:00', 'Agente2', 'Supervisor3', 'Motivo1', 'Done', 'Canal2', 'US');

-- Atualizar campos Data_Hora_Atualização e Data_Hora_Fechamento
-- Descrição: Define as datas de atualização e fechamento para os casos especificados.
UPDATE histCasosTrabalhados
SET Data_Hora_Atualização = GETDATE()
WHERE Id_Caso in (25551, 25552);

UPDATE histCasosTrabalhados
SET Data_Hora_Fechamento = GETDATE()
WHERE Id_Caso in (25551, 25552) AND Status = 'Done';

-- Inserir dados na tabela dimCalendario
-- Descrição: Preenche a tabela de dimensão dimCalendario com as datas dos casos trabalhados.
INSERT INTO dimCalendario (Data_Hora_Criação, Ano, Mes, Dia)
SELECT DISTINCT
    Data_Hora_Criação,
    YEAR(Data_Hora_Criação) AS Ano,
    MONTH(Data_Hora_Criação) AS Mes,
    DAY(Data_Hora_Criação) AS Dia
FROM histCasosTrabalhados;

-- Inserir dados na tabela dimFuncionario
-- Descrição: Preenche a tabela de dimensão dimFuncionario com os nomes dos agentes.
INSERT INTO dimFuncionario (NomeAgen)
SELECT DISTINCT NomeAgen
FROM histCasosTrabalhados
WHERE NomeAgen IS NOT NULL;

-- Inserir dados na tabela dimSupervisor
-- Descrição: Preenche a tabela de dimensão dimSupervisor com os nomes dos supervisores.
INSERT INTO dimSupervisor (NomeSupe)
SELECT DISTINCT NomeSupe
FROM histCasosTrabalhados
WHERE NomeSupe IS NOT NULL;

-- Inserir dados na tabela dimMotiChamador
-- Descrição: Preenche a tabela de dimensão dimMotiChamador com os motivos dos chamadores.
INSERT INTO dimMotiChamador (Motivo_Chamador)
SELECT DISTINCT Motivo_Chamador
FROM histCasosTrabalhados
WHERE Motivo_Chamador IS NOT NULL;

-- Inserir dados na tabela dimStatus
-- Descrição: Preenche a tabela de dimensão dimStatus com os status dos casos.
INSERT INTO dimStatus (Status)
SELECT DISTINCT Status
FROM histCasosTrabalhados
WHERE Status IS NOT NULL;

-- Inserir dados na tabela dimCanalEntrada
-- Descrição: Preenche a tabela de dimensão dimCanalEntrada com os canais de entrada utilizados.
INSERT INTO dimCanalEntrada (Canal_Entrada)
SELECT DISTINCT Canal_Entrada
FROM histCasosTrabalhados
WHERE Canal_Entrada IS NOT NULL;

-- Inserir dados na tabela dimPais
-- Descrição: Preenche a tabela de dimensão dimPais com os países registrados nos casos trabalhados.
INSERT INTO dimPais (País)
SELECT DISTINCT País
FROM histCasosTrabalhados
WHERE País IS NOT NULL;
