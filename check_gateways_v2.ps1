# Verificacao dos gateways 205-208 apos religamento
Write-Host "=============================================="
Write-Host " VERIFICACAO GATEWAYS - $(Get-Date)"
Write-Host "=============================================="

# 1. Ping
Write-Host ""
Write-Host "=== 1. PING NOS GATEWAYS ==="
$gateways = @(
    @{IP='172.16.176.205'; Nome='Gateway #205 (NOVO)'},
    @{IP='172.16.176.206'; Nome='Gateway Advansus #206'},
    @{IP='172.16.176.207'; Nome='Gateway #207 (NOVO)'},
    @{IP='172.16.176.208'; Nome='Gateway Advantech #208'},
    @{IP='172.16.176.209'; Nome='Gateway Advantech #209'}
)
foreach ($h in $gateways) {
    $ping = Test-Connection -ComputerName $h.IP -Count 2 -Quiet -ErrorAction SilentlyContinue
    $status = if ($ping) { "ONLINE" } else { "OFFLINE" }
    if ($ping) {
        $result = Test-Connection -ComputerName $h.IP -Count 1 -ErrorAction SilentlyContinue
        $latency = " ($($result.ResponseTime)ms)"
    } else {
        $latency = ""
    }
    Write-Host "  $($h.IP) [$($h.Nome)]: $status$latency"
}

# 2. Scan TCP 102 (MMS)
Write-Host ""
Write-Host "=== 2. TESTE TCP 102 (MMS) ==="
foreach ($h in $gateways) {
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $connect = $tcp.BeginConnect($h.IP, 102, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(2000, $false)
        if ($wait -and $tcp.Connected) {
            Write-Host "  $($h.IP) porta 102: ABERTA!" -ForegroundColor Green
        } else {
            Write-Host "  $($h.IP) porta 102: FECHADA/FILTERED" -ForegroundColor Red
        }
        $tcp.Close()
    } catch {
        Write-Host "  $($h.IP) porta 102: ERRO - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 3. Scan portas adicionais
Write-Host ""
Write-Host "=== 3. SCAN DE PORTAS COMPLETO ==="
$portas = @(21, 80, 102, 135, 443, 502, 1947, 3389, 4840, 8080)
foreach ($h in $gateways) {
    $abertas = @()
    foreach ($p in $portas) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        try {
            $connect = $tcp.BeginConnect($h.IP, $p, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne(800, $false)
            if ($wait -and $tcp.Connected) {
                $abertas += $p
            }
            $tcp.Close()
        } catch {
            $tcp.Close()
        }
    }
    if ($abertas.Count -gt 0) {
        Write-Host "  $($h.IP) [$($h.Nome)]: $($abertas -join ', ')"
    } else {
        Write-Host "  $($h.IP) [$($h.Nome)]: nenhuma porta aberta" -ForegroundColor Red
    }
}

# 4. ARP para ver MACs
Write-Host ""
Write-Host "=== 4. TABELA ARP (GATEWAYS) ==="
arp -a -N 172.16.176.233 | Select-String "176\.(205|206|207|208|209)"
