import pyodbc

# Estabelece conexão com o banco de dados SQL Server e executa uma procedure
try:
    # Conexão com o banco de dados
    conn = pyodbc.connect(
        'DRIVER={SQL Server};'
        'SERVER=DALEVEDOVE\\SQLEXPRESS;'
        'DATABASE=ProvaBI;'
        'Trusted_Connection=yes;'
    )
    cursor = conn.cursor()

    # Executa a procedure AtualizarDimensoesEFato
    cursor.execute("EXEC dbo.AtualizarDimensoesEFato")
    conn.commit()
    print("Procedure executada com sucesso!")

except pyodbc.Error as e:
    # Tratamento de erros relacionados ao banco de dados
    print(f"Erro de conexão ou execução no banco de dados: {e}")

except Exception as e:
    # Tratamento de erros gerais
    print(f"Erro inesperado: {e}")

finally:
    # Fecha a conexão com o banco de dados, se aberta
    if 'conn' in locals() and conn:
        conn.close()
        print("Conexão com o banco de dados encerrada.")