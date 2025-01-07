-- Trigger: Trigger_AtualizarDimensoesEFato
-- Descrição: Dispara a execução da procedure AtualizarDimensoesEFato sempre que houver uma inserção ou atualização na tabela histCasosTrabalhados.
CREATE TRIGGER Trigger_AtualizarDimensoesEFato
ON histCasosTrabalhados
AFTER INSERT, UPDATE
AS
BEGIN
    EXEC AtualizarDimensoesEFato;
END;

-- Trigger: trg_Update_HoraAtualizacao
-- Descrição: Atualiza o campo Data_Hora_Atualização com a data e hora atual sempre que um registro na tabela histCasosTrabalhados for atualizado.
CREATE TRIGGER trg_Update_HoraAtualizacao
ON histCasosTrabalhados
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualiza a Data_Hora_Atualização com o timestamp atual
    UPDATE histCasosTrabalhados
    SET Data_Hora_Atualização = GETDATE()
    WHERE Id_Caso IN (SELECT Id_Caso FROM Inserted);
END;

-- Trigger: trg_Update_HoraFechamento
-- Descrição: Atualiza o campo Data_Hora_Fechamento somente quando o campo Status for alterado para "Done" ou equivalente, garantindo que não sobrescreva valores existentes.
CREATE TRIGGER trg_Update_HoraFechamento
ON histCasosTrabalhados
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualiza a Data_Hora_Fechamento somente se o status for "Done" e o campo ainda estiver vazio
    UPDATE histCasosTrabalhados
    SET Data_Hora_Fechamento = GETDATE()
    WHERE Id_Caso IN (SELECT Id_Caso FROM Inserted)
      AND Status = 'Done' -- Ajuste conforme necessário
      AND Data_Hora_Fechamento IS NULL;
END;

-- Alteração: trg_Update_HoraAtualizacao
-- Descrição: Evita recursão ao garantir que o gatilho não seja chamado novamente por sua própria execução.
ALTER TRIGGER trg_Update_HoraAtualizacao
ON histCasosTrabalhados
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Evita recursão ao atualizar a tabela
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    -- Atualiza a Data_Hora_Atualização
    UPDATE histCasosTrabalhados
    SET Data_Hora_Atualização = GETDATE()
    WHERE Id_Caso IN (SELECT Id_Caso FROM Inserted);
END;

-- Desativação de Triggers
-- Descrição: Temporariamente desativa os gatilhos para execução de testes ou manutenção na tabela histCasosTrabalhados.
DISABLE TRIGGER Trigger_AtualizarDimensoesEFato ON histCasosTrabalhados;
DISABLE TRIGGER trg_Update_HoraAtualizacao ON histCasosTrabalhados;
DISABLE TRIGGER trg_Update_HoraFechamento ON histCasosTrabalhados;

-- Reativação de Triggers
-- Descrição: Reativa os gatilhos após testes ou manutenções na tabela histCasosTrabalhados.
ENABLE TRIGGER Trigger_AtualizarDimensoesEFato ON histCasosTrabalhados;
ENABLE TRIGGER trg_Update_HoraAtualizacao ON histCasosTrabalhados;
ENABLE TRIGGER trg_Update_HoraFechamento ON histCasosTrabalhados;