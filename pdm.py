#!/usr/bin/env python3.8
"""
Nome do Script: Nome_do_Script.py
Propósito: Descrição breve do objetivo do script.
Autor: Seu Nome
Data de criação: Data de criação do script
Versão: 1.0
Python: 3.8
"""

# -------------------------------------
import paramiko
import pyodbc
import argparse
import os
import datetime
# -------------------------------------


# -----------------------------------------------------------------------------
def connect_remote_pswh
    # SSH connection details
    host = 'remote_server_ip'
    username = 'username'
    password = 'password'
    port = 22

    # PowerShell script to execute remotely
    powershell_script = '''
    # Your PowerShell script goes here
    Write-Host "Hello, PowerShell!"
    '''

    # Establish SSH connection
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=host, port=port, username=username, password=password)

    # Execute PowerShell script remotely
    stdin, stdout, stderr = ssh.exec_command('powershell.exe -command -', get_pty=True)
    stdin.write(powershell_script)
    stdin.channel.shutdown_write()

    # Print the output of the PowerShell script
    output = stdout.read().decode()
    error = stderr.read().decode()
    print('Output:')
    print(output)

    if error:
        print('Error:')
        print(error)

    # Close the SSH connection
    ssh.close()

# -----------------------------------------------------------------------------
def connect_mssql

    # Configurar os detalhes de conexão
    server = 'localhost,1433'
    database = 'tempdb'
    username = 'sa'
    password = 'yourStrong(!)Password'
    driver = '{ODBC Driver 17 for SQL Server}'  # Driver ODBC apropriado

    # Construir a string de conexão
    connection_string = f'server={server};database={database};uid={username};pwd={password};driver={driver}'

    # Tentar estabelecer a conexão
    try:
        conn = pyodbc.connect(connection_string)
        print('Conexão estabelecida com sucesso!')
        
        # Criação de um cursor
        cursor = conn.cursor()

        # Evocação da consulta
        query = "SELECT getdate()"
        cursor.execute(query)

        # Processamento dos resultados
        for row in cursor:
            print(row)

        # Fechamento do cursor e da conexão
        cursor.close()
        
        conn.close()  # Fechar a conexão quando terminar
        
    except pyodbc.Error as e:
        print('Erro ao conectar ao banco de dados:')
        print(e)


# -----------------------------------------------------------------------------
# # Exemplo de uso
# caminho = 'caminho/do/arquivo.txt'  # Substitua pelo caminho do arquivo desejado

# idade = calcular_idade_em_horas(caminho)
# if idade is not None:
#     print(f"A idade do arquivo '{caminho}' é de aproximadamente {idade:.2f} horas.")
# else:
#     print(f"O arquivo '{caminho}' não foi encontrado.")
def calcular_idade_em_horas(caminho_arquivo):
    if os.path.exists(caminho_arquivo):
        data_modificacao = datetime.datetime.fromtimestamp(os.path.getmtime(caminho_arquivo))
        data_atual = datetime.datetime.now()
        diferenca = data_atual - data_modificacao
        idade_em_horas = diferenca.total_seconds() / 3600  # Converter para horas
        return idade_em_horas
    else:
        return None



# -----------------------------------------------------------------------------
# Criar o objeto ArgumentParser
parser = argparse.ArgumentParser(description='Descrição do programa')

# Adicionar opções/flags
parser.add_argument('-a', '--opcao_a', action='store_true', help='Descrição da opção A')
parser.add_argument('-b', '--opcao_b', type=int, help='Descrição da opção B')

# Analisar os argumentos de linha de comando
args = parser.parse_args()

# Acessar os valores das opções
if args.opcao_a:
    print('Opção A ativada')

if args.opcao_b:
    print(f'Opção B: {args.opcao_b}')
