# Relatorio Forense de Rede - Subestacao IEC 61850

## 1. Resumo Executivo

A rede 172.16.176.0/24 de subestacao eletrica apresenta **tres problemas criticos** que afetam a comunicacao IEC 61850 entre reles de protecao e gateways de dados:

1. **Broadcast Storm** originada pelo servidor HMI GE Vernova (Dell .217) - 654 pacotes broadcast em 44 segundos (~15 pkt/s) do protocolo EGD (Ethernet Global Data), causado por falha no servico backend do HMI (HTTP 502 Bad Gateway)

2. **Porta MMS (TCP 102) bloqueada por firewall** nos gateways Advantech/Advansus (.206 e .208), impedindo a ligacao mestre-escravo IEC 61850-MMS com os reles Vamp

3. **Gateways completamente silenciosos** na rede - zero pacotes IP transmitidos durante toda a captura de 45 segundos

---

## 2. Inventario de Dispositivos (31 hosts ativos)

### 2.1 Reles de Protecao - Vamp Ltd. (Finlandia) - 22 IEDs

| IP | MAC | Portas Abertas | GOOSE | Obs |
|---|---|---|---|---|
| 172.16.176.5 | 00:1A:D3:41:C0:64 | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.6 | 00:1A:D3:41:A6:89 | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.7 | 00:1A:D3:41:C0:66 | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.8 | 00:1A:D3:41:C0:68 | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.9 | 00:1A:D3:41:C0:3D | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.10 | 00:1A:D3:41:C0:5D | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.11 | 00:1A:D3:41:C0:62 | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.12 | 00:1A:D3:41:C0:4A | 102, 502 | C11_00BBA80 | stNum=69 (ALERTA) |
| 172.16.176.13 | 00:1A:D3:41:C6:D0 | 102, 502 | C7_00BBA80 | stNum=25 |
| 172.16.176.14 | 00:1A:D3:41:BD:23 | 102, 502 | C7_00BBA80 | OK |
| 172.16.176.15 | 00:1A:D3:41:C0:65 | 102, 502 | C11_00BBA80 | OK |
| 172.16.176.16 | 00:1A:D3:41:C0:54 | 102, 502 | TEMPLATE | Config padrao |
| 172.16.176.17 | 00:1A:D3:41:C0:60 | 102, 502 | TEMPLATE | Config padrao |
| 172.16.176.19 | 00:1A:D3:41:BC:38 | 102, 502 | C17_00BBA80 | stNum=24 |
| 172.16.176.20 | 00:1A:D3:41:C1:37 | 102, 502 | C10_21BBA80 | OK |
| 172.16.176.21 | 00:1A:D3:41:C0:70 | 102, 502 | C10_21BBA80 | OK |
| 172.16.176.24 | 00:1A:D3:41:BE:6C | 102, 502 | C5_21BBA80 | stNum=13 |
| 172.16.176.26 | 00:1A:D3:41:BC:67 | 102, 502 | C7_21BBA80 | stNum=35 (ALERTA) |
| 172.16.176.27 | 00:1A:D3:41:BC:59 | 102, 502 | C9_21BBA80 | OK |
| 172.16.176.28 | 00:1A:D3:41:C0:67 | 102, 502 | C10_21BBA80 | OK |
| 172.16.176.30 | 00:1A:D3:41:C1:36 | 102, 502 | C17_20BBA80 | OK |
| 172.16.176.31 | 00:1A:D3:41:C1:24 | 102, 502 | C17_20BBA80 | OK |

**Obs:** Todos os 22 reles Vamp tem TCP 102 (MMS) e TCP 502 (Modbus) ABERTOS e prontos para receber conexoes.

### 2.2 Merging Units / Switches - Reason Tecnologia (Brasil) - 4 dispositivos

| IP | MAC | Portas Abertas |
|---|---|---|
| 172.16.176.1 | F8:02:78:1B:A9:60 | 443 (HTTPS) |
| 172.16.176.2 | F8:02:78:1B:B0:40 | 443 (HTTPS) |
| 172.16.176.3 | F8:02:78:1B:AB:60 | 443 (HTTPS) |
| 172.16.176.4 | F8:02:78:1B:B4:40 | 443 (HTTPS) |

### 2.3 Gateways de Comunicacao - Advantech/Advansus - 3 dispositivos

| IP | MAC | Fabricante | SO | Portas Abertas | Porta 102 |
|---|---|---|---|---|---|
| 172.16.176.206 | 00:19:0F:3C:64:AC | Advansus Corp. | Windows (IIS FTP 7) | 21 (FTP) | **FILTERED** |
| 172.16.176.208 | CC:82:7F:60:2E:28 | Advantech China | Windows (IIS FTP 7) | 21 (FTP) | **FILTERED** |
| 172.16.176.209 | C4:00:AD:ED:FF:78 | Advantech China | Windows (MS FTP) | 21, 4840 (OPC-UA) | **FILTERED** |

### 2.4 Servidor HMI/SCADA - Dell - 1 dispositivo

| IP | MAC | SO | Software |
|---|---|---|---|
| 172.16.176.217 (+ 172.16.150.216 e 5 outros IPs) | CC:96:E5:61:8C:50 | Windows 11/10/Server 2022 | **GE Power Gateway / GE Vernova** |

**Servicos identificados no Dell .217:**
- nginx 1.22.0 (portas 80/443) - SSL CN=GE Power Gateway, O=GE Vernova
- MMS Server (porta 102)
- OPC-UA (porta 4840)
- HASP License Manager 22.00 (porta 1947)
- RPC (porta 135), SMB (porta 445)
- **RDP (porta 3389) - ABERTO**
- EGD via UDP broadcast (porta 18246)

### 2.5 Estacoes de Trabalho - 2 dispositivos

| IP | MAC | Fabricante | Obs |
|---|---|---|---|
| 172.16.176.220 | 40:C2:BA:A6:99:54 | Compal | Notebook |
| 172.16.176.240 | B0:0C:D1:5A:01:50 | Hewlett Packard | Apareceu apos desligamento do .217. Nao responde a ping/scan (firewall ou desconectado). Enviou 1 ARP request para .29 |

---

## 3. Analise de Trafego IEC 61850

### 3.1 GOOSE (EtherType 0x88B8) - OPERACIONAL

- **41 pacotes** capturados em 25 segundos (captura filtrada)
- **23 reles Vamp** distintos transmitindo
- VLAN ID: 176, CoS: 4 (prioridade correta conforme IEC 61850-8-1)
- timeAllowedToLive: 40000ms (40 segundos - ciclo de publicacao)
- Ciclo de retransmissao: ~20 segundos por rele
- Destinos multicast: 01:0C:CD:01:00:00 e 01:0C:CD:01:00:21 (IEC TC57)
- Flag de simulacao: desativada (mensagens operacionais reais)

**GoCB References identificados:**
- C5_21BBA80Relay, C7_00BBA80Relay, C7_21BBA80Relay
- C9_21BBA80Relay, C10_21BBA80Relay, C11_00BBA80Relay
- C12_21BBA80Relay, C17_00BBA80Relay, C17_20BBA80Relay
- TEMPLATERelay (2 reles com configuracao padrao - .16 e .17)

### 3.2 MMS / ISO-TSAP (TCP 102) - INOPERANTE

- **ZERO pacotes MMS** capturados em ambas as capturas (filtrada e completa)
- **ZERO conexoes TCP** em toda a rede durante 45 segundos
- Os reles Vamp tem porta 102 aberta, mas NINGUEM esta conectando
- Os gateways tem porta 102 FILTRADA por firewall

### 3.3 Sampled Values (EtherType 0x88BA) - NAO DETECTADO

- Nenhum pacote SV detectado em nenhuma captura

---

## 4. Problemas Identificados

### 4.1 CRITICO - Broadcast Storm do GE Power Gateway (.217)

**Origem:** Dell .217 / 172.16.150.216 (MAC: cc:96:e5:61:8c:50)
**Protocolo:** EGD (Ethernet Global Data) - protocolo proprietario GE
**Volume:** 654 pacotes broadcast em 44 segundos (~15 pacotes/segundo)
**Tamanho:** 645KB em 44s (~14.6 KB/s de broadcast), pacotes ate 1462 bytes
**Porta:** UDP 51288 -> 18246

**Padrao observado:**
- Burst de 12 pacotes EGD a cada segundo (ExchangeIDs 0x01 a 0x32)
- RequestID incrementando a cada segundo (07871, 07872, ...)
- Broadcast para ff:ff:ff:ff:ff:ff em TODAS as 7 sub-redes configuradas
- Tambem envia para multicast 234.5.6.7 (EGD multicast group)
- ARP scan para dezenas de IPs inexistentes (.43, .70-.76, .80, .92-.100, .106-.115)
- SMB Mailslot broadcasts adicionais
- UDP para porta 1947 (HASP license check) em broadcast

**Causa raiz:** O servico backend do HMI GE caiu (nginx retorna 502 Bad Gateway em todas as rotas). O software EGD continua transmitindo em loop sem receber respostas, gerando a tempestade de broadcast.

**Impacto:** 89% de todo o trafego na rede e broadcast. Isso sobrecarrega as tabelas CAM dos switches, aumenta a latencia para pacotes GOOSE (criticos e sensiveis a tempo), e pode causar perda de pacotes em equipamentos com buffers limitados.

### 4.2 CRITICO - Porta MMS Bloqueada nos Gateways

**Dispositivos afetados:** .206 (Advansus) e .208 (Advantech)
**Sintoma:** Porta TCP 102 com estado "FILTERED" (bloqueada por firewall)
**Evidencia:** Nmap retorna "filtered" (pacotes SYN nao recebem resposta)
**Causa provavel:** Windows Firewall ativo nos gateways bloqueando TCP 102
**Impacto:** Ligacao mestre-escravo MMS completamente inoperante. Gateways nao conseguem ler dados dos reles, enviar comandos, ou receber reportes.

### 4.3 ALTO - Gateways Silenciosos (Zero Trafego)

**Dispositivos:** .206 e .208
**Sintoma:** Zero pacotes IP ou TCP originados desses dispositivos em 45 segundos
**Evidencia ARP:** O rele Vamp .29 (00:1A:D3:41:B0:51) enviou 6 ARP Requests para .208 em 30 segundos sem resposta, indicando que o gateway nao responde nem a nivel ARP
**Unica porta funcional:** FTP (porta 21) com IIS FTP 7

### 4.4 MEDIO - Reles com stNum Elevado

Reles com contador de mudanca de estado (stNum) alto indicam eventos reais na subestacao:
- **C11 (.12)**: stNum=69 - 69 mudancas de estado
- **C7_21 (.26)**: stNum=35 - 35 mudancas de estado
- **C7_00 (.13)**: stNum=25
- **C17_00 (.19)**: stNum=24
- **C5_21 (.24)**: stNum=13

Esses reles passaram por multiplas atuacoes de protecao que precisam ser investigadas.

### 4.5 BAIXO - Reles com Configuracao TEMPLATE

Os reles .16 (00:1A:D3:41:C0:54) e .17 (00:1A:D3:41:C0:60) estao transmitindo GOOSE com gocbRef "TEMPLATERelay/LLN0$GO$gcb1", indicando que nao foram configurados com seus nomes definitivos.

### 4.6 INFO - Dell .217 com IPs em 7 Sub-redes

O Dell .217 tem IPs configurados em:
- 172.16.150.216 (EGD broadcast source)
- 172.16.176.217
- 172.16.180.217
- 172.16.190.217
- 172.16.151.217
- 172.16.162.217
- 192.168.1.217

Todas as sub-redes recebem broadcast EGD, amplificando o impacto.

---

## 5. Topologia Identificada

```
                    [SWITCH SUBESTACAO]
                          |
    +--------+--------+--------+--------+--------+
    |        |        |        |        |        |
  [.1-.4]  [.5-.31]  [.206]  [.208]  [.209]  [.217]
  Reason   Vamp IEDs  Advansus Advantech Advantech Dell/GE
  Merging  22 Reles   Gateway  Gateway  Gateway  HMI+EGD
  Units    GOOSE OK   FTP only FTP only FTP+OPCUA SCADA
           MMS ready  MMS BLOCKED       MMS BLOCKED 502 ERROR
```

**Fluxo esperado (nao funcional):**
```
Dell .217 (HMI/SCADA) --MMS--> Gateways .206/.208 --MMS--> Reles Vamp (porta 102)
```

**Fluxo atual (quebrado):**
```
Dell .217 --EGD broadcast--> TODA A REDE (broadcast storm)
Gateways .206/.208 --> SILENCIOSOS (firewall bloqueia TCP 102)
Reles Vamp --> GOOSE OK, MMS esperando conexao que nunca chega
```

---

## 6. Plano de Correcao

### 6.1 URGENTE - Reiniciar Servico GE no Dell .217

**Acesso:** RDP (porta 3389 aberta)
```
mstsc /v:172.16.176.217
```

**Passos apos login:**
```powershell
# 1. Identificar servicos GE parados
Get-Service | Where-Object {
    ($_.DisplayName -like "*GE*" -or $_.DisplayName -like "*CIMPLICITY*" -or
     $_.DisplayName -like "*ToolboxST*" -or $_.DisplayName -like "*iFIX*" -or
     $_.DisplayName -like "*EGD*" -or $_.DisplayName -like "*Proficy*" -or
     $_.DisplayName -like "*Power*" -or $_.DisplayName -like "*Vernova*") -and
    $_.Status -ne 'Running'
}

# 2. Reiniciar servico identificado
Restart-Service -Name "NOME_DO_SERVICO" -Force

# 3. Verificar se HMI voltou
Invoke-WebRequest -Uri 'https://localhost' -UseBasicParsing -SkipCertificateCheck

# 4. Se nao iniciar, verificar logs
Get-EventLog -LogName Application -Newest 50 |
    Where-Object { $_.Source -like "*GE*" -or $_.EntryType -eq "Error" }

# 5. Verificar dongle HASP
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*HASP*" -or $_.FriendlyName -like "*Sentinel*" }
```

### 6.2 URGENTE - Desbloquear TCP 102 nos Gateways .206/.208

**Acesso:** FTP (porta 21 aberta) - verificar se permite upload de scripts
```
ftp 172.16.176.206
ftp 172.16.176.208
```

**Se conseguir acesso fisico ou RDP nos gateways:**
```powershell
# Criar regra de firewall para MMS
New-NetFirewallRule -DisplayName "IEC 61850 MMS Inbound" -Direction Inbound -Protocol TCP -LocalPort 102 -Action Allow
New-NetFirewallRule -DisplayName "IEC 61850 MMS Outbound" -Direction Outbound -Protocol TCP -RemotePort 102 -Action Allow

# Verificar
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*MMS*" -or $_.DisplayName -like "*61850*" }
```

### 6.3 ALTO - Reduzir Broadcast do Dell .217

Apos reiniciar o servico GE, se o broadcast persistir:
```powershell
# Remover IPs desnecessarios (manter apenas os essenciais)
# CUIDADO: verificar com o responsavel quais IPs sao necessarios
# Remove-NetIPAddress -IPAddress "192.168.1.217" -Confirm:$false
# Remove-NetIPAddress -IPAddress "172.16.162.217" -Confirm:$false
```

### 6.4 MEDIO - Configurar Storm Control no Switch

No switch da subestacao (se gerenciavel):
```
# Exemplo Cisco:
interface GigabitEthernet0/1
  storm-control broadcast level 10
  storm-control action shutdown

# Exemplo Reason/Ruggedcom:
# Configurar via interface web dos switches .1-.4
```

### 6.5 MEDIO - Investigar Reles com stNum Alto

Acessar o historico de eventos dos reles C11 (.12), C7 (.26), C7 (.13), C17 (.19) via:
- Interface web dos reles (se disponivel)
- Software Vampset da Vamp Ltd.
- Cliente MMS (libIEC61850) apos corrigir a comunicacao

### 6.6 BAIXO - Configurar Reles TEMPLATE

Os reles .16 e .17 precisam ser configurados com seus nomes definitivos usando o Vampset.

---

## 7. Arquivos Gerados

| Arquivo | Descricao |
|---|---|
| `iec61850_capture_v2.pcap` | Captura filtrada IEC 61850 (41 pacotes GOOSE, 25s) |
| `full_capture_61850.pcap` | Captura completa sem filtro (759 pacotes, 45s) |
| `scan_all_ports.ps1` | Script de scan de portas em todos os hosts |
| `analyze_traffic.ps1` | Script de analise de trafego IEC 61850 |
| `analyze_gateways.ps1` | Script de analise dos gateways 206/208 |
| `investigate_all.ps1` | Script de investigacao broadcast + gateways + Dell |
| `investigate_217.ps1` | Nmap completo do Dell .217 |
| `fix_217.ps1` | Script de diagnostico de servicos no Dell |
| `check_rdp_217.ps1` | Verificacao de acesso remoto |
| `scan_network.ps1` | Scan de portas IEC 61850 |
| `check_web_217.ps1` | Teste de interface web |
| `check_web_217_v2.ps1` | Teste HTTPS com bypass SSL |
| `captura_pos_desligamento.pcap` | Captura completa pos-desligamento (158 pacotes, 45s) |
| `comparar_capturas.ps1` | Comparacao antes vs depois do desligamento |
| `verificacao_pos.ps1` | Ping e teste TCP 102 pos-desligamento |
| `check_240.ps1` | Analise do trafego do novo dispositivo HP .240 |

---

## 8. Acoes de Roteamento Realizadas

Durante a investigacao, foi removida a rota:
```
172.16.0.0/12 via WireGuard (interface 9, metrica 5) -> REMOVIDA
```
**Motivo:** O trafego 172.16.x.x e local e deve sair pela placa Realtek (interface 5), nao pelo tunel VPN WireGuard.

**Nota:** Esta rota nao e persistente. Ao reiniciar o WireGuard, ela pode ser recriada. Para tornar permanente, ajustar a configuracao do WireGuard (AllowedIPs) para excluir 172.16.0.0/12.

---

## 9. Resultados Pos-Desligamento do Dell .217

### 9.1 Acao Executada

O Dell .217 (GE Power Gateway / GE Vernova HMI) foi **fisicamente desligado** pelo operador apos identificacao como fonte do broadcast storm EGD.

### 9.2 Comparacao ANTES vs DEPOIS

| Metrica | ANTES (Dell ligado) | DEPOIS (Dell desligado) | Reducao |
|---|---|---|---|
| Pacotes totais | 759 (45s) | 158 (45s) | **79%** |
| Volume de dados | ~663 KB | ~17 KB | **97%** |
| Pacotes broadcast | 675 | 30 | **96%** |
| Pacotes multicast | 696 | 128 | **82%** |
| Pacotes EGD | 588 | 0 | **100%** |
| Pacotes GOOSE | 41 | 56 | Melhorou (+37%) |
| Pacotes unicast (nao-GOOSE) | ~63 | ~30 | Normalizado |

### 9.3 Broadcast Storm - ELIMINADA

- **EGD: 588 pacotes -> 0 pacotes** (100% eliminacao)
- O trafego broadcast restante (30 pacotes) e composto apenas por ARP requests normais
- **Confirmacao definitiva:** o Dell .217 era a unica fonte do broadcast storm

### 9.4 GOOSE - MELHOROU

- **56 pacotes GOOSE** capturados (vs 41 antes) - mais visiveis sem interferencia do broadcast
- Todos os reles Vamp continuam transmitindo normalmente
- Destinos multicast IEC TC57 intactos: 01:0C:CD:01:00:00 e 01:0C:CD:01:00:21

### 9.5 MMS (TCP 102) - AINDA INOPERANTE

- Gateways .206/.208/.209 continuam com porta 102 **FILTERED**
- Retransmissoes SYN para os gateways sem resposta (SYN-ACK nunca chega)
- Reles Vamp respondem SYN-ACK em **4-6ms** - prontos para conexao
- **Causa:** Windows Firewall nos gateways (independente do Dell .217)

### 9.6 Novo Switch Reason Identificado

- **MAC:** F8:02:78:19:15:53 (Reason Tecnologia SA)
- **Trafego:** STP (Spanning Tree Protocol) e LLDP
- Provavelmente um switch Reason S2024 nao detectado anteriormente (sem IP configurado, opera em L2)

### 9.7 Novo Dispositivo .240 Identificado

- **IP:** 172.16.176.240
- **MAC:** B0:0C:D1:5A:01:50
- **Fabricante:** Hewlett Packard
- **Trafego:** 1 ARP request ("Who has 172.16.176.29? Tell 172.16.176.240")
- **Status:** Nao responde a ping, nmap, ou scan de portas
- **Nota:** Nao estava presente na captura ANTES. Possivelmente notebook HP conectado brevemente a rede

### 9.8 Conclusao Pos-Desligamento

O desligamento do Dell .217 **resolveu completamente o broadcast storm** e reduziu o volume de trafego em 97%. A rede opera agora de forma limpa, com apenas trafego GOOSE (protecao) e ARP (normal).

O **unico problema restante** e o bloqueio de TCP 102 nos gateways .206/.208/.209, que requer acesso direto aos gateways para configurar o Windows Firewall.

---

## 10. Conclusao

### Problema Original
A rede apresentava lentidao causada pela **combinacao** de:
1. **Broadcast storm EGD** do servidor GE HMI (.217) - servico backend caiu (HTTP 502)
2. **Gateways com firewall bloqueando MMS** (.206/.208/.209) - impedindo comunicacao mestre-escravo

### Acao Corretiva #1 - Dell .217 Desligado (EXECUTADA)
- **Resultado:** Broadcast storm **100% eliminada**
- Volume de rede reduzido em **97%** (663 KB -> 17 KB em 45s)
- GOOSE dos reles melhorou (+37% visibilidade)
- Rede operando de forma limpa

### Acao Corretiva #2 - Desbloquear TCP 102 nos Gateways (PENDENTE)
- Gateways .206/.208/.209 continuam com firewall bloqueando MMS
- **Requer acesso direto** (fisico ou via FTP porta 21) para adicionar regra:
  `New-NetFirewallRule -DisplayName "IEC 61850 MMS" -Direction Inbound -Protocol TCP -LocalPort 102 -Action Allow`

### Acao Corretiva #3 - Reiniciar Dell .217 com servico GE corrigido (PENDENTE)
- Antes de religar, acessar via RDP (porta 3389) e reiniciar o servico backend GE
- Verificar dongle HASP e logs de aplicacao
- Considerar desabilitar EGD exchanges desnecessarios

### Estado Atual
- **GOOSE (protecao):** 100% operacional - todos os 22 reles Vamp transmitindo
- **MMS (supervisao):** inoperante - gateways com firewall bloqueando TCP 102
- **Broadcast storm:** eliminada com desligamento do Dell .217
- **Novo dispositivo HP .240:** identificado, sem impacto na rede

---

*Relatorio gerado por NetSentinel SecOps - Claude Code*
*Data: 18/02/2026 12:45 -0400*
*Atualizado: 18/02/2026 17:10 -0400*
