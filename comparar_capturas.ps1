# Comparacao ANTES vs DEPOIS do desligamento do Dell .217
$tshark = "C:\Program Files\Wireshark\tshark.exe"
$antes = "C:\Users\ricar\network-forensics-cli\full_capture_61850.pcap"
$depois = "C:\Users\ricar\network-forensics-cli\captura_pos_desligamento.pcap"

Write-Host "=============================================="
Write-Host " COMPARACAO ANTES vs DEPOIS - $(Get-Date)"
Write-Host "=============================================="

# 1. Estatisticas gerais
Write-Host ""
Write-Host "=== ANTES (com Dell .217 ligado) ==="
& $tshark -r $antes -q -z io,stat,0 2>$null

Write-Host ""
Write-Host "=== DEPOIS (Dell .217 desligado) ==="
& $tshark -r $depois -q -z io,stat,0 2>$null

# 2. Hierarquia de protocolos DEPOIS
Write-Host ""
Write-Host "=== PROTOCOLOS DEPOIS ==="
& $tshark -r $depois -q -z phs 2>$null

# 3. Broadcast DEPOIS
Write-Host ""
Write-Host "=== CONTAGEM BROADCAST/MULTICAST DEPOIS ==="
$total = (& $tshark -r $depois -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
$bcast = (& $tshark -r $depois -Y "eth.dst==ff:ff:ff:ff:ff:ff" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
$mcast = (& $tshark -r $depois -Y "eth.ig==1" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
$goose = (& $tshark -r $depois -Y "goose" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
$egd = (& $tshark -r $depois -Y "egd" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
Write-Host "Total pacotes:  $total"
Write-Host "Broadcast:      $bcast"
Write-Host "Multicast:      $mcast"
Write-Host "GOOSE:          $goose"
Write-Host "EGD:            $egd"
Write-Host "Unicast:        $($total - $bcast - $mcast + $goose)"

# 4. Trafego EGD restante?
Write-Host ""
Write-Host "=== EGD RESTANTE (deve ser ZERO) ==="
& $tshark -r $depois -Y "egd" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e _ws.col.Info 2>$null | Select-Object -First 10

# 5. Trafego Dell .217 restante?
Write-Host ""
Write-Host "=== TRAFEGO DO DELL .217 (deve ser ZERO) ==="
& $tshark -r $depois -Y "eth.src==cc:96:e5:61:8c:50 or eth.dst==cc:96:e5:61:8c:50" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null | Select-Object -First 10

# 6. TCP/MMS agora
Write-Host ""
Write-Host "=== TRAFEGO MMS (TCP 102) ==="
& $tshark -r $depois -Y "tcp.port==102" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.flags.str -e frame.len 2>$null

# 7. GOOSE
Write-Host ""
Write-Host "=== GOOSE ATIVO ==="
& $tshark -r $depois -Y "goose" -T fields -e frame.number -e frame.time_relative -e eth.src -e goose.gocbRef -e goose.stNum -e goose.sqNum 2>$null

# 8. Conversacoes IP
Write-Host ""
Write-Host "=== CONVERSACOES IP ==="
& $tshark -r $depois -q -z conv,ip 2>$null

# 9. Conversacoes TCP
Write-Host ""
Write-Host "=== CONVERSACOES TCP ==="
& $tshark -r $depois -q -z conv,tcp 2>$null

# 10. Endpoints
Write-Host ""
Write-Host "=== ENDPOINTS IP ==="
& $tshark -r $depois -q -z endpoints,ip 2>$null

# 11. ARP
Write-Host ""
Write-Host "=== ARP REQUESTS ==="
& $tshark -r $depois -Y "arp" -T fields -e frame.number -e frame.time_relative -e arp.src.hw_mac -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.opcode -e _ws.col.Info 2>$null

# 12. Trafego nao-GOOSE, nao-broadcast
Write-Host ""
Write-Host "=== TRAFEGO UNICAST (nao-GOOSE, nao-broadcast) ==="
& $tshark -r $depois -Y "not goose and not eth.dst==ff:ff:ff:ff:ff:ff and not arp and eth.ig==0" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e ip.src -e ip.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null

# 13. Novo dispositivo .240
Write-Host ""
Write-Host "=== TRAFEGO DO NOVO DISPOSITIVO .240 ==="
& $tshark -r $depois -Y "eth.src==b0:0c:d1:5a:01:50 or eth.dst==b0:0c:d1:5a:01:50 or ip.addr==172.16.176.240" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null

Write-Host ""
Write-Host "=== FIM ==="
