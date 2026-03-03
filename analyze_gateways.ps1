# Analise focada nos gateways 206/208 e comunicacao MMS mestre-escravo
$tshark = "C:\Program Files\Wireshark\tshark.exe"
$pcap = "C:\Users\ricar\network-forensics-cli\full_capture_61850.pcap"

Write-Host "=============================================="
Write-Host " ANALISE GATEWAYS 206/208 - MESTRE-ESCRAVO MMS"
Write-Host " $(Get-Date)"
Write-Host "=============================================="
Write-Host ""

# 0. Estatisticas gerais da captura
Write-Host "=== 0. ESTATISTICAS DA CAPTURA COMPLETA ==="
& $tshark -r $pcap -q -z io,stat,0 2>$null
Write-Host ""

# 0b. Hierarquia de protocolos
Write-Host "=== 0b. HIERARQUIA DE PROTOCOLOS ==="
& $tshark -r $pcap -q -z phs 2>$null
Write-Host ""

# 1. TODO trafego do gateway .206
Write-Host "=== 1. TODO TRAFEGO DO GATEWAY .206 (Advansus) ==="
& $tshark -r $pcap -Y "ip.addr==172.16.176.206" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e ip.proto -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e frame.len -e _ws.col.Protocol 2>$null
Write-Host ""

# 2. TODO trafego do gateway .208
Write-Host "=== 2. TODO TRAFEGO DO GATEWAY .208 (Advantech) ==="
& $tshark -r $pcap -Y "ip.addr==172.16.176.208" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e ip.proto -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e frame.len -e _ws.col.Protocol 2>$null
Write-Host ""

# 3. Trafego MMS (TCP 102) em toda a rede
Write-Host "=== 3. TODO TRAFEGO MMS (TCP 102) ==="
& $tshark -r $pcap -Y "tcp.port==102" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e tcp.analysis.retransmission -e tcp.analysis.rto -e frame.len 2>$null
Write-Host ""

# 4. Tentativas de conexao TCP (SYN) dos gateways para os reles
Write-Host "=== 4. TENTATIVAS DE CONEXAO (SYN) DOS GATEWAYS ==="
& $tshark -r $pcap -Y "(ip.src==172.16.176.206 or ip.src==172.16.176.208 or ip.src==172.16.176.209) and tcp.flags.syn==1" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e tcp.analysis.retransmission 2>$null
Write-Host ""

# 5. RST/FIN - conexoes rejeitadas ou encerradas
Write-Host "=== 5. CONEXOES REJEITADAS (RST) OU ENCERRADAS (FIN) ==="
& $tshark -r $pcap -Y "(ip.addr==172.16.176.206 or ip.addr==172.16.176.208) and (tcp.flags.reset==1 or tcp.flags.fin==1)" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags.str 2>$null
Write-Host ""

# 6. Retransmissoes e problemas TCP
Write-Host "=== 6. RETRANSMISSOES E PROBLEMAS TCP ==="
& $tshark -r $pcap -Y "tcp.analysis.retransmission or tcp.analysis.duplicate_ack or tcp.analysis.fast_retransmission or tcp.analysis.zero_window or tcp.analysis.window_full" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e _ws.col.Info 2>$null
Write-Host ""

# 7. Trafego ARP dos gateways (resolvendo MACs)
Write-Host "=== 7. ARP DOS GATEWAYS ==="
& $tshark -r $pcap -Y "arp and (arp.src.proto_ipv4==172.16.176.206 or arp.src.proto_ipv4==172.16.176.208 or arp.dst.proto_ipv4==172.16.176.206 or arp.dst.proto_ipv4==172.16.176.208)" -T fields -e frame.number -e frame.time_relative -e arp.src.hw_mac -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 -e arp.opcode 2>$null
Write-Host ""

# 8. Conversacoes IP completas
Write-Host "=== 8. CONVERSACOES IP ==="
& $tshark -r $pcap -q -z conv,ip 2>$null
Write-Host ""

# 9. Conversacoes TCP
Write-Host "=== 9. CONVERSACOES TCP ==="
& $tshark -r $pcap -q -z conv,tcp 2>$null
Write-Host ""

# 10. Endpoints IP (quem gera mais trafego)
Write-Host "=== 10. ENDPOINTS IP (VOLUME DE TRAFEGO) ==="
& $tshark -r $pcap -q -z endpoints,ip 2>$null
Write-Host ""

# 11. Trafego entre gateways e estacao Dell .217
Write-Host "=== 11. TRAFEGO GATEWAY <-> DELL .217 ==="
& $tshark -r $pcap -Y "(ip.addr==172.16.176.217) and (ip.addr==172.16.176.206 or ip.addr==172.16.176.208)" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e frame.len 2>$null
Write-Host ""

# 12. Qualquer trafego Modbus (porta 502)
Write-Host "=== 12. TRAFEGO MODBUS (TCP 502) ==="
& $tshark -r $pcap -Y "tcp.port==502" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e frame.len 2>$null
Write-Host ""

# 13. Trafego OPC-UA (porta 4840)
Write-Host "=== 13. TRAFEGO OPC-UA (TCP 4840) ==="
& $tshark -r $pcap -Y "tcp.port==4840" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e tcp.flags.str -e frame.len 2>$null
Write-Host ""

# 14. Broadcast/Multicast excessivo (causa de lentidao)
Write-Host "=== 14. CONTAGEM BROADCAST/MULTICAST ==="
$total = & $tshark -r $pcap -T fields -e frame.number 2>$null | Measure-Object -Line
$bcast = & $tshark -r $pcap -Y "eth.dst==ff:ff:ff:ff:ff:ff" -T fields -e frame.number 2>$null | Measure-Object -Line
$mcast = & $tshark -r $pcap -Y "eth.ig==1" -T fields -e frame.number 2>$null | Measure-Object -Line
Write-Host "Total pacotes: $($total.Lines)"
Write-Host "Broadcast: $($bcast.Lines)"
Write-Host "Multicast: $($mcast.Lines)"
Write-Host "Unicast: $($total.Lines - $bcast.Lines - $mcast.Lines)"
Write-Host ""

Write-Host "=== FIM DA ANALISE ==="
