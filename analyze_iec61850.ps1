# NetSentinel - Analise IEC 61850
# Script PowerShell para diagnostico de protocolo IEC 61850

$TSHARK = "C:\Program Files\Wireshark\tshark.exe"
$PCAP   = "C:\Users\ricar\network-forensics-cli\080324.pcap"

Write-Host "=== NetSentinel: Diagnostico IEC 61850 ===" -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# 1. Estatisticas gerais do arquivo
Write-Host "[1] Estatisticas gerais do arquivo pcap:" -ForegroundColor Yellow
$stats = & $TSHARK -r $PCAP -q -z io,phs 2>&1
$stats | Select-Object -First 40

Write-Host ""
Write-Host "[2] Contagem de protocolos detectados:" -ForegroundColor Yellow
$protos = & $TSHARK -r $PCAP -q -z io,stat,0,"tcp","udp","icmp" 2>&1
$protos | Select-Object -First 30

Write-Host ""
Write-Host "[3] Lista de conversacoes IP (top flows):" -ForegroundColor Yellow
$convs = & $TSHARK -r $PCAP -q -z conv,ip 2>&1
$convs | Select-Object -First 40

Write-Host ""
Write-Host "[4] Verificando trafego IEC 61850 - MMS (porta TCP 102):" -ForegroundColor Yellow
$mms = & $TSHARK -r $PCAP -Y "tcp.port == 102" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "tcp.dstport" -e "frame.len" 2>&1
if ($mms.Count -eq 0 -or $mms -match "^\s*$") {
    Write-Host "  -> Nenhum pacote MMS (porta 102) encontrado no arquivo."
} else {
    $mms | Select-Object -First 30
}

Write-Host ""
Write-Host "[5] Verificando trafego GOOSE (EtherType 0x88B8):" -ForegroundColor Yellow
$goose = & $TSHARK -r $PCAP -Y "eth.type == 0x88b8" -T fields -e "frame.number" -e "frame.time_relative" -e "eth.src" -e "eth.dst" -e "frame.len" 2>&1
if ($goose.Count -eq 0 -or $goose -match "^\s*$") {
    Write-Host "  -> Nenhum pacote GOOSE (0x88B8) encontrado no arquivo."
} else {
    $goose | Select-Object -First 30
}

Write-Host ""
Write-Host "[6] Verificando Sampled Values / SV (EtherType 0x88BA):" -ForegroundColor Yellow
$sv = & $TSHARK -r $PCAP -Y "eth.type == 0x88ba" -T fields -e "frame.number" -e "frame.time_relative" -e "eth.src" -e "eth.dst" -e "frame.len" 2>&1
if ($sv.Count -eq 0 -or $sv -match "^\s*$") {
    Write-Host "  -> Nenhum pacote SV (0x88BA) encontrado no arquivo."
} else {
    $sv | Select-Object -First 30
}

Write-Host ""
Write-Host "[7] Verificando pacotes ARP (deteccao de spoofing):" -ForegroundColor Yellow
$arp = & $TSHARK -r $PCAP -Y "arp" -T fields -e "frame.number" -e "frame.time_relative" -e "eth.src" -e "arp.src.proto_ipv4" -e "arp.dst.proto_ipv4" -e "arp.opcode" 2>&1
if ($arp.Count -eq 0 -or $arp -match "^\s*$") {
    Write-Host "  -> Nenhum pacote ARP encontrado."
} else {
    $arp | Select-Object -First 30
}

Write-Host ""
Write-Host "[8] IPs de destino mais frequentes (possivel C2 ou exfiltration):" -ForegroundColor Yellow
$topips = & $TSHARK -r $PCAP -T fields -e "ip.dst" 2>&1 | Where-Object { $_ -notmatch "^\s*$" } | Group-Object | Sort-Object Count -Descending | Select-Object -First 15
$topips | Format-Table -AutoSize

Write-Host ""
Write-Host "[9] Verificando portas de destino TCP (deteccao de scanning):" -ForegroundColor Yellow
$ports = & $TSHARK -r $PCAP -T fields -e "tcp.dstport" 2>&1 | Where-Object { $_ -notmatch "^\s*$" -and $_ -ne "" } | Group-Object | Sort-Object Count -Descending | Select-Object -First 20
$ports | Format-Table -AutoSize

Write-Host ""
Write-Host "[10] Verificando pacotes grandes (> 1400 bytes - possivel exfiltracao):" -ForegroundColor Yellow
$big = & $TSHARK -r $PCAP -Y "frame.len > 1400" -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" -e "frame.len" 2>&1
$bigCount = ($big | Where-Object { $_ -notmatch "^\s*$" }).Count
Write-Host "  -> Total de pacotes grandes encontrados: $bigCount"
if ($bigCount -gt 0) {
    $big | Select-Object -First 20
}

Write-Host ""
Write-Host "[11] Estatisticas de tempo e frequencia de pacotes (deteccao de beaconing):" -ForegroundColor Yellow
$timing = & $TSHARK -r $PCAP -T fields -e "frame.number" -e "frame.time_relative" -e "ip.src" -e "ip.dst" 2>&1 | Select-Object -First 5
Write-Host "Primeiros e ultimos timestamps:"
$timing
$totalFrames = & $TSHARK -r $PCAP -T fields -e "frame.number" 2>&1 | Measure-Object
Write-Host "Total de pacotes no arquivo: $($totalFrames.Count)"

Write-Host ""
Write-Host "=== Analise concluida ===" -ForegroundColor Cyan
