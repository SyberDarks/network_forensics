# Analise profunda do trafego IEC 61850 capturado
$tshark = "C:\Program Files\Wireshark\tshark.exe"
$pcap = "C:\Users\ricar\network-forensics-cli\iec61850_capture_v2.pcap"

Write-Host "=============================================="
Write-Host " ANALISE IEC 61850 - $(Get-Date)"
Write-Host "=============================================="
Write-Host ""

# 1. Estatisticas gerais
Write-Host "=== 1. ESTATISTICAS GERAIS ==="
& $tshark -r $pcap -q -z io,stat,0 2>$null
Write-Host ""

# 2. Protocolos encontrados
Write-Host "=== 2. HIERARQUIA DE PROTOCOLOS ==="
& $tshark -r $pcap -q -z phs 2>$null
Write-Host ""

# 3. GOOSE - Analise detalhada
Write-Host "=== 3. PACOTES GOOSE (EtherType 0x88b8) ==="
& $tshark -r $pcap -Y "goose" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e goose.gocbRef -e goose.stNum -e goose.sqNum -e goose.timeAllowedtoLive -e frame.len 2>$null
Write-Host ""

# 4. MMS - TCP 102
Write-Host "=== 4. PACOTES MMS (TCP 102) ==="
& $tshark -r $pcap -Y "tcp.port==102" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.flags -e tcp.analysis.retransmission -e tcp.analysis.rto -e frame.len 2>$null
Write-Host ""

# 5. Retransmissoes TCP (indicador de lentidao)
Write-Host "=== 5. RETRANSMISSOES TCP (PROBLEMA DE LENTIDAO) ==="
& $tshark -r $pcap -Y "tcp.analysis.retransmission or tcp.analysis.duplicate_ack or tcp.analysis.fast_retransmission" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.port -e tcp.analysis.retransmission 2>$null
Write-Host ""

# 6. Latencia entre pacotes GOOSE (delta time)
Write-Host "=== 6. TIMING GOOSE - DELTA ENTRE PACOTES ==="
& $tshark -r $pcap -Y "goose" -T fields -e frame.number -e frame.time_delta -e eth.src -e goose.gocbRef -e goose.timeAllowedtoLive 2>$null
Write-Host ""

# 7. Conversacoes (quem fala com quem)
Write-Host "=== 7. CONVERSACOES ETHERNET ==="
& $tshark -r $pcap -q -z conv,eth 2>$null
Write-Host ""

# 8. Conversacoes IP
Write-Host "=== 8. CONVERSACOES IP ==="
& $tshark -r $pcap -q -z conv,ip 2>$null
Write-Host ""

# 9. ARP - Possivel storm ou conflito
Write-Host "=== 9. TRAFEGO ARP (conflitos/storms) ==="
& $tshark -r $pcap -Y "arp" -T fields -e frame.number -e frame.time_relative -e arp.src.hw_mac -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.opcode 2>$null
Write-Host ""

# 10. Pacotes com erros
Write-Host "=== 10. PACOTES COM ERROS ==="
& $tshark -r $pcap -Y "tcp.analysis.flags or _ws.malformed" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.analysis.flags 2>$null
Write-Host ""

Write-Host "=== FIM DA ANALISE ==="
