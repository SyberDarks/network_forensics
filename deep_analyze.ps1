# NetSentinel - Analise Profunda IEC 61850 / Anomalias

$TSHARK = "C:\Program Files\Wireshark\tshark.exe"
$PCAP   = "C:\Users\ricar\network-forensics-cli\080324.pcap"

Write-Host "--- Detalhes TLS e conexoes externas ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "tls" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "tls.handshake.type" -e "tls.record.version" -e "frame.len" 2>&1

Write-Host ""
Write-Host "--- ARP Gratuito / Probe (IPs 0.0.0.0) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "arp.src.proto_ipv4 == 0.0.0.0" -T fields -e "frame.number" -e "frame.time_relative" -e "eth.src" -e "arp.src.proto_ipv4" -e "arp.dst.proto_ipv4" 2>&1

Write-Host ""
Write-Host "--- IGMP (Multicast memberships - relevante para GOOSE/SV) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "igmp" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "igmp.type" 2>&1

Write-Host ""
Write-Host "--- DNS queries (deteccao de tunneling) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "dns" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "dns.qry.name" -e "dns.resp.name" 2>&1

Write-Host ""
Write-Host "--- MDNS queries (dispositivos se anunciando na rede) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "mdns" -T fields -e "frame.number" -e "ip.src" -e "dns.qry.name" 2>&1 | Select-Object -First 20

Write-Host ""
Write-Host "--- Conexao com IP vietnamita 118.69.17.47 (maior volume de dados) ---" -ForegroundColor Red
& $TSHARK -r $PCAP -Y "ip.addr == 118.69.17.47" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "tcp.srcport" -e "tcp.dstport" -e "tcp.flags" -e "frame.len" 2>&1

Write-Host ""
Write-Host "--- Verificar retransmissoes TCP (indicativo de latencia ou instabilidade) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "tcp.analysis.retransmission" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "frame.len" 2>&1
$retrans = & $TSHARK -r $PCAP -Y "tcp.analysis.retransmission" -T fields -e "frame.number" 2>&1
Write-Host "Total retransmissoes: $(($retrans | Where-Object {$_ -notmatch '^\s*$'}).Count)"

Write-Host ""
Write-Host "--- Verificar RST (conexoes abortadas) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "tcp.flags.reset == 1" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "tcp.srcport" -e "tcp.dstport" 2>&1

Write-Host ""
Write-Host "--- Intervalos entre pacotes para IP 49.213.95.132 (beaconing check) ---" -ForegroundColor Yellow
& $TSHARK -r $PCAP -Y "ip.addr == 49.213.95.132" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "tcp.dstport" -e "frame.len" 2>&1
