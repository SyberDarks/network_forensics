# NetSentinel - Memoria Operacional

## Ambiente de Rede Identificado
- Host principal: 192.168.0.175 (Intel MAC c0:b6:f9:72:d3:64) - rede Wi-Fi domestica
- Gateway Wi-Fi: 192.168.0.1 (TpLink MAC 50:d4:f7:ef:23:a9)
- Rede IEC 61850: 172.16.176.0/24 - interface Ethernet (Realtek PCIe GbE)
- IP local na rede IEC 61850: 172.16.176.233

## Ferramentas Disponiveis
- tshark: OPERACIONAL em C:\Program Files\Wireshark\tshark.exe (v4.6.3)
- python: OPERACIONAL em C:\Users\ricar\AppData\Local\Programs\Python
- mcpcap: NAO verificado ainda (tentar na proxima sessao)
- audit_rede.py: disponivel mas aponta para caminho incorreto (interactiveCLI.py inexistente)

## Mapeamento CRITICO de Interfaces TShark (tshark -D)
- TShark #5  = Conexao de Rede Bluetooth (NAO usar para Realtek)
- TShark #6  = Wi-Fi (Intel AX211) - rede 192.168.x.x
- TShark #10 = Ethernet (Realtek PCIe GbE) - rede 172.16.x.x - INTERFACE IEC 61850
- TShark #4  = vEthernet (cowork-vm-nat) - 172.16.0.1
- TShark #11 = vEthernet (Default Switch) - 172.25.192.1
- ATENCAO: InterfaceIndex do Windows NAO corresponde ao numero do TShark. Usar tshark -D para confirmar.

## Execucao de Scripts PowerShell
- USAR: powershell -ExecutionPolicy Bypass -File "caminho_absoluto.ps1"
- NAO usar variaveis com $ em -Command inline (o shell bash interpreta o $)
- SEMPRE usar scripts .ps1 para comandos complexos com variaveis PowerShell

## Rede IEC 61850 - 172.16.176.0/24 (Levantamento 18/02/2026)
### Dispositivos Ativos (5 hosts)
- 172.16.176.205: MAC 00-19-0F-3B-6E-B7 | Advansus Corp. (Taiwan) | Portas: 80/443 ABERTAS
- 172.16.176.206: MAC 00-19-0F-3C-64-AC | Advansus Corp. (Taiwan) | Sem portas abertas
- 172.16.176.207: MAC 74-FE-48-93-D4-24 | Advantech Co. Ltd (Taiwan) | Portas: 80/443 ABERTAS
- 172.16.176.208: MAC CC-82-7F-60-2E-28 | Advantech Technology China | Sem portas abertas
- 172.16.176.209: MAC C4-00-AD-ED-FF-78 | Advantech Technology China | Sem portas abertas

### Dispositivos GOOSE observados na captura (OUI 00:1A:D3 = Vamp Ltd. - Finlandia)
- Reles de protecao Vamp Ltd. emitindo GOOSE via VLAN 176 CoS 4
- gocbRef identificados: C5, C7, C9, C10, C11, C12, C17 + TEMPLATE
- stNum variados (1, 2, 13, 24, 25, 35, 69) = eventos reais ocorridos

### Protocolos IEC 61850 na Rede
- GOOSE (0x88B8): ATIVO - 39 pacotes em 30 segundos via VLAN 176 CoS 4
- MMS (TCP 102): FECHADO em todos os 5 hosts escaneados
- Sampled Values (0x88BA): NAO detectado na captura de 30s

## Analise GOOSE - Anomalias Encontradas (18/02/2026)
- sqNum com valores altos (21327, 29829) = longa operacao sem reset (normal)
- sqNum baixos (17, 130, 281) = possivel reinicializacao recente de alguns reles
- stNum=69 no gcb C11_00 = 69 mudancas de estado (alto - investigar)
- stNum=35 no gcb C7_21 = 35 mudancas de estado (moderado)
- Sem GOOSE malformados, sem retransmissoes TCP
- Nao foi possivel verificar flag TEST via campo goose.test (campo invalido no TShark 4.6.3)
  - Alternativa: usar goose.reserve1.s_bit para verificar bit de simulacao

## Padroes de Script Funcionais
- C:\Users\ricar\network-forensics-cli\scan_iec61850_ports.ps1 - scan TCP IEC 61850
- C:\Users\ricar\network-forensics-cli\capture_iec61850_v3.ps1 - captura GOOSE/MMS/SV
- C:\Users\ricar\network-forensics-cli\analyze_goose_deep.ps1 - analise GOOSE detalhada
- C:\Users\ricar\network-forensics-cli\analyze_iec61850.ps1 - analise legado
- Arquivo capturado: C:\Users\ricar\network-forensics-cli\iec61850_capture.pcap

## IPs Suspeitos Anteriores (pcap 080324.pcap - rede domestica)
- 118.69.17.47: IP vietnamita / Akamai CDN (Zalo)
- 49.213.95.132: TLS 1.0 obsoleto (vulneravel)
- NENHUM trafego IEC 61850 naquele arquivo
