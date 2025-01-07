-- Criar banco de dados ProvaBI
-- Descrição: Banco de dados que armazena informações de casos trabalhados, incluindo tabelas de dimensões e fatos para análise.
CREATE DATABASE ProvaBI;
GO

-- Tabela: histCasosTrabalhados
-- Descrição: Tabela que armazena o histórico de casos trabalhados, incluindo informações do país, canal de entrada e status.
CREATE TABLE histCasosTrabalhados (
    Id_Caso BIGINT PRIMARY KEY,
    País NVARCHAR(2),
    Canal_Entrada NVARCHAR(50),
    Status NVARCHAR(20),
    Resolução NVARCHAR(10),
    Motivo_Chamador NVARCHAR(255),
    NomeAgen NVARCHAR(255),
    NomeSupe NVARCHAR(255),
    Data_Hora_Criação DATETIME,
    Data_Hora_Atualização DATETIME,
    Data_Hora_Fechamento DATETIME
);

-- Tabela: dimCalendario
-- Descrição: Tabela de dimensão para armazenar datas e seus componentes (ano, mês, dia).
CREATE TABLE dimCalendario (
    Data_Hora_Criação DATETIME PRIMARY KEY,
    Ano INT,
    Mes INT,
    Dia INT
);

-- Tabela: dimFuncionario
-- Descrição: Tabela de dimensão que armazena informações sobre agentes funcionários.
CREATE TABLE dimFuncionario (
    IdFuncionario INT IDENTITY PRIMARY KEY,
    NomeAgen NVARCHAR(255)
);

-- Tabela: dimSupervisor
-- Descrição: Tabela de dimensão que armazena informações sobre supervisores.
CREATE TABLE dimSupervisor (
    IdSupervisor INT IDENTITY PRIMARY KEY,
    NomeSupe NVARCHAR(255)
);

-- Tabela: dimMotiChamador
-- Descrição: Tabela de dimensão que armazena os motivos dos chamadores.
CREATE TABLE dimMotiChamador (
    IdMotivo INT IDENTITY PRIMARY KEY,
    Motivo_Chamador NVARCHAR(255)
);

-- Tabela: dimStatus
-- Descrição: Tabela de dimensão que armazena os status dos casos.
CREATE TABLE dimStatus (
    IdStatus INT IDENTITY PRIMARY KEY,
    Status NVARCHAR(20)
);

-- Tabela: dimCanalEntrada
-- Descrição: Tabela de dimensão que armazena os canais de entrada utilizados.
CREATE TABLE dimCanalEntrada (
    IdCanalEntrada INT IDENTITY PRIMARY KEY,
    Canal_Entrada NVARCHAR(255)
);

-- Tabela: dimPais
-- Descrição: Tabela de dimensão que armazena informações sobre os países.
CREATE TABLE dimPais (
    IdPais INT IDENTITY PRIMARY KEY,
    País NVARCHAR(255)
);

-- Tabela: fatoCasos
-- Descrição: Tabela fato que consolida informações de casos, relacionando dimensões como calendário, funcionários e status.
CREATE TABLE fatoCasos (
    IdCalendario INT,
    IdFuncionario INT,
    IdSupervisor INT,
    IdMotivo INT,
    IdStatus INT,
    IdCanalEntrada INT,
    IdPais INT,
    TotalCasosFechados INT,
    TotalCasosAbertos INT,
    PercentualResolucao FLOAT,
    TempoMedioAtualizacao FLOAT,
    TempoMedioFechamento FLOAT,
    PRIMARY KEY (IdCalendario, IdFuncionario, IdSupervisor, IdMotivo, IdStatus, IdCanalEntrada, IdPais)
);