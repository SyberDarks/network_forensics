# NetSentinel - Scan de Portas IEC 61850
# Testa TCP 102 (MMS/ISO-TSAP) e TCP 3721 (HSR/PRP) nos hosts da rede
# Data: 18/02/2026

$hosts = @(
    "172.16.176.205",
    "172.16.176.206",
    "172.16.176.207",
    "172.16.176.208",
    "172.16.176.209"
)

$ports = @(
    @{ Port = 102;  Name = "MMS/ISO-TSAP (IEC 61850 principal)" },
    @{ Port = 3721; Name = "HSR/PRP (Alta disponibilidade IEC 62439)" },
    @{ Port = 80;   Name = "HTTP (Mgmt Web)" },
    @{ Port = 443;  Name = "HTTPS (Mgmt Web seguro)" },
    @{ Port = 23;   Name = "Telnet (Mgmt legado)" },
    @{ Port = 22;   Name = "SSH (Mgmt seguro)" }
)

Write-Host ""
Write-Host "=== SCAN DE PORTAS IEC 61850 ===" -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "Rede alvo: 172.16.176.0/24" -ForegroundColor Gray
Write-Host "Timeout por porta: 1 segundo`n" -ForegroundColor Gray

$resultados = @()

foreach ($host_ip in $hosts) {
    Write-Host "--- Testando host: $host_ip ---" -ForegroundColor Yellow

    # Teste de ping primeiro
    $ping = Test-Connection -ComputerName $host_ip -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($ping) {
        Write-Host "  [PING] Ativo (responde ICMP)" -ForegroundColor Green
    } else {
        Write-Host "  [PING] Sem resposta ICMP (pode ter firewall)" -ForegroundColor DarkYellow
    }

    foreach ($portInfo in $ports) {
        $port = $portInfo.Port
        $portName = $portInfo.Name

        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $connect = $tcp.BeginConnect($host_ip, $port, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne(1000, $false)

            if ($wait -and $tcp.Connected) {
                Write-Host "  [ABERTA] Porta $port ($portName)" -ForegroundColor Green
                $status = "ABERTA"
                $tcp.Close()
            } else {
                Write-Host "  [FECHADA] Porta $port ($portName)" -ForegroundColor Red
                $status = "FECHADA"
            }
            $tcp.Close()
        } catch {
            Write-Host "  [ERRO] Porta $port ($portName) - $($_.Exception.Message)" -ForegroundColor DarkRed
            $status = "ERRO"
        }

        $resultados += [PSCustomObject]@{
            IP     = $host_ip
            Porta  = $port
            Nome   = $portName
            Status = $status
        }
    }
    Write-Host ""
}

Write-Host "=== RESUMO DO SCAN ===" -ForegroundColor Cyan
$portasAbertas = $resultados | Where-Object { $_.Status -eq "ABERTA" }
if ($portasAbertas.Count -gt 0) {
    Write-Host "Portas abertas encontradas:" -ForegroundColor Green
    $portasAbertas | Format-Table -AutoSize
} else {
    Write-Host "Nenhuma porta aberta detectada nos hosts testados." -ForegroundColor Red
    Write-Host "Possivel causa: firewall bloqueando ou servicos nao iniciados." -ForegroundColor Yellow
}

# Verificar tshark
Write-Host "`n=== VERIFICACAO DO TSHARK ===" -ForegroundColor Cyan
$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
if (Test-Path $tsharkPath) {
    $version = & $tsharkPath --version 2>&1 | Select-Object -First 1
    Write-Host "TShark DISPONIVEL: $version" -ForegroundColor Green
} else {
    Write-Host "TShark NAO encontrado em: $tsharkPath" -ForegroundColor Red
}
