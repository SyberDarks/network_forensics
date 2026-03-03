import subprocess
import sys
import os

# Configurações
TEMPO_CAPTURA = "20"  # Segundos
ARQUIVO_TEMP = "temp_capture.pcap"
CAMINHO_FORENSE = r"C:\Users\ricar\network_forensics\interactiveCLI.py" # Confirme se é main.py ou interactiveCLI.py

def capturar_trafego(filtro=""):
    print(f"--- Iniciando captura de rede por {TEMPO_CAPTURA} segundos ---")
    if filtro:
        print(f"Filtro aplicado: {filtro}")
    
    # Comando do TShark (ajuste o caminho se não estiver no PATH)
    cmd = ["tshark", "-a", f"duration:{TEMPO_CAPTURA}", "-w", ARQUIVO_TEMP]
    
    if filtro:
        cmd.extend(["-f", filtro])

    try:
        subprocess.run(cmd, check=True)
        print("Captura concluída com sucesso.")
    except FileNotFoundError:
        print("ERRO: TShark não encontrado. Instale o Wireshark e adicione ao PATH.")
        sys.exit(1)

def analisar_captura():
    print("--- Iniciando análise forense ---")
    # Chama a sua ferramenta atual passando o arquivo recém-criado
    cmd = ["python", CAMINHO_FORENSE, "-r", ARQUIVO_TEMP]
    
    resultado = subprocess.run(cmd, capture_output=True, text=True)
    print(resultado.stdout)
    
    if resultado.stderr:
        print("Erros/Avisos:", resultado.stderr)

if __name__ == "__main__":
    # Pega argumentos extras (ex: 'tcp port 80') passados pelo Claude
    filtro_rede = " ".join(sys.argv[1:])
    
    capturar_trafego(filtro_rede)
    analisar_captura()
    
    # Limpeza (opcional)
    # os.remove(ARQUIVO_TEMP)