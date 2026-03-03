# Investigacao completa - Gateways, Broadcast Storm, Dell .217
$tshark = "C:\Program Files\Wireshark\tshark.exe"
$pcap = "C:\Users\ricar\network-forensics-cli\full_capture_61850.pcap"

Write-Host "=============================================="
Write-Host " INVESTIGACAO COMPLETA - $(Get-Date)"
Write-Host "=============================================="

# ===== PARTE 1: BROADCAST STORM =====
Write-Host ""
Write-Host "######################################"
Write-Host "# PARTE 1: BROADCAST STORM ANALYSIS #"
Write-Host "######################################"
Write-Host ""

Write-Host "=== 1.1 ORIGEM DO BROADCAST - 172.16.150.216 ==="
Write-Host "Pacotes broadcast por protocolo:"
& $tshark -r $pcap -Y "ip.src==172.16.150.216" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e ip.proto -e udp.srcport -e udp.dstport -e frame.len -e _ws.col.Protocol -e _ws.col.Info 2>$null | Select-Object -First 30
Write-Host ""

Write-Host "=== 1.2 MAC DO 172.16.150.216 ==="
& $tshark -r $pcap -Y "ip.src==172.16.150.216" -T fields -e eth.src -e eth.dst 2>$null | Select-Object -First 3
Write-Host ""

Write-Host "=== 1.3 TODOS OS BROADCASTS POR ORIGEM (contagem) ==="
& $tshark -r $pcap -Y "eth.dst==ff:ff:ff:ff:ff:ff" -T fields -e eth.src -e ip.src 2>$null | Sort-Object | Get-Unique -AsString | ForEach-Object {
    $src = $_
    $count = (& $tshark -r $pcap -Y "eth.src==$($src.Split("`t")[0]) and eth.dst==ff:ff:ff:ff:ff:ff" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
    Write-Host "$src : $count pacotes"
}
Write-Host ""

Write-Host "=== 1.4 DISTRIBUICAO TEMPORAL DO BROADCAST (pacotes/segundo) ==="
& $tshark -r $pcap -Y "ip.src==172.16.150.216" -q -z io,stat,5 2>$null
Write-Host ""

# ===== PARTE 2: GATEWAYS .206 e .208 =====
Write-Host ""
Write-Host "######################################"
Write-Host "# PARTE 2: GATEWAYS 206/208/209      #"
Write-Host "######################################"
Write-Host ""

Write-Host "=== 2.1 NMAP SERVICOS GATEWAY .206 ==="
nmap -sV -p 21,22,23,80,102,443,502,3721,4840,8080,8443,161 --send-eth -e eth1 172.16.176.206 2>&1
Write-Host ""

Write-Host "=== 2.2 NMAP SERVICOS GATEWAY .208 ==="
nmap -sV -p 21,22,23,80,102,443,502,3721,4840,8080,8443,161 --send-eth -e eth1 172.16.176.208 2>&1
Write-Host ""

Write-Host "=== 2.3 NMAP SERVICOS GATEWAY .209 ==="
nmap -sV -p 21,22,23,80,102,443,502,3721,4840,8080,8443,161 --send-eth -e eth1 172.16.176.209 2>&1
Write-Host ""

Write-Host "=== 2.4 TODOS OS PACOTES ETHERNET COM MAC DOS GATEWAYS ==="
Write-Host "--- MAC .206 (00:19:0f:3c:64:ac) ---"
& $tshark -r $pcap -Y "eth.src==00:19:0f:3c:64:ac or eth.dst==00:19:0f:3c:64:ac" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null
Write-Host ""
Write-Host "--- MAC .208 (cc:82:7f:60:2e:28) ---"
& $tshark -r $pcap -Y "eth.src==cc:82:7f:60:2e:28 or eth.dst==cc:82:7f:60:2e:28" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null
Write-Host ""
Write-Host "--- MAC .209 (c4:00:ad:ed:ff:78) ---"
& $tshark -r $pcap -Y "eth.src==c4:00:ad:ed:ff:78 or eth.dst==c4:00:ad:ed:ff:78" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null
Write-Host ""

# ===== PARTE 3: DELL .217 =====
Write-Host ""
Write-Host "######################################"
Write-Host "# PARTE 3: ESTACAO DELL .217          #"
Write-Host "######################################"
Write-Host ""

Write-Host "=== 3.1 NMAP SERVICOS DELL .217 ==="
nmap -sV -p 21,22,23,80,102,443,502,3721,4840,8080,8443,161,3306,1433,5432 --send-eth -e eth1 172.16.176.217 2>&1
Write-Host ""

Write-Host "=== 3.2 TODO TRAFEGO IP DO .217 ==="
& $tshark -r $pcap -Y "ip.addr==172.16.176.217 or ip.addr==172.16.180.217 or ip.addr==172.16.190.217 or ip.addr==172.16.151.217 or ip.addr==172.16.162.217 or ip.addr==192.168.1.217" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e ip.proto -e udp.srcport -e udp.dstport -e frame.len -e _ws.col.Protocol -e _ws.col.Info 2>$null
Write-Host ""

Write-Host "=== 3.3 MAC DO .217 E PACOTES ETHERNET ==="
& $tshark -r $pcap -Y "eth.src==cc:96:e5:61:8c:50 or eth.dst==cc:96:e5:61:8c:50" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null
Write-Host ""

Write-Host "=== 3.4 ARP DO .217 ==="
& $tshark -r $pcap -Y "arp and (arp.src.proto_ipv4 contains 217 or arp.dst.proto_ipv4 contains 217)" -T fields -e frame.number -e frame.time_relative -e arp.src.hw_mac -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.opcode 2>$null
Write-Host ""

# ===== PARTE 4: QUEM FALA COM QUEM =====
Write-Host ""
Write-Host "######################################"
Write-Host "# PARTE 4: MAPA DE COMUNICACAO       #"
Write-Host "######################################"
Write-Host ""

Write-Host "=== 4.1 TODOS ARP REQUESTS/REPLIES ==="
& $tshark -r $pcap -Y "arp" -T fields -e frame.number -e frame.time_relative -e arp.src.hw_mac -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.opcode -e _ws.col.Info 2>$null
Write-Host ""

Write-Host "=== 4.2 TRAFEGO NAO-GOOSE E NAO-BROADCAST ==="
& $tshark -r $pcap -Y "not goose and not eth.dst==ff:ff:ff:ff:ff:ff and not arp" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info -e frame.len 2>$null
Write-Host ""

Write-Host "=== FIM DA INVESTIGACAO ==="
