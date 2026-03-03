# Verificacao pos-desligamento do Dell .217
Write-Host "=============================================="
Write-Host " VERIFICACAO POS-DESLIGAMENTO - $(Get-Date)"
Write-Host "=============================================="

# 1. Ping rapido nos dispositivos criticos
Write-Host ""
Write-Host "=== 1. PING NOS DISPOSITIVOS CRITICOS ==="
$hosts = @(
    @{IP='172.16.176.1'; Nome='Reason #1'},
    @{IP='172.16.176.5'; Nome='Vamp #5'},
    @{IP='172.16.176.10'; Nome='Vamp #10'},
    @{IP='172.16.176.20'; Nome='Vamp #20'},
    @{IP='172.16.176.206'; Nome='Gateway Advansus'},
    @{IP='172.16.176.208'; Nome='Gateway Advantech'},
    @{IP='172.16.176.209'; Nome='Gateway Advantech #2'},
    @{IP='172.16.176.217'; Nome='Dell GE (DESLIGADO)'},
    @{IP='172.16.176.220'; Nome='Notebook Compal'}
)
foreach ($h in $hosts) {
    $ping = Test-Connection -ComputerName $h.IP -Count 1 -TimeoutSeconds 2 -Quiet -ErrorAction SilentlyContinue
    $status = if ($ping) { "ONLINE" } else { "OFFLINE" }
    $latency = ""
    if ($ping) {
        $result = Test-Connection -ComputerName $h.IP -Count 1 -ErrorAction SilentlyContinue
        $latency = " ($($result.ResponseTime)ms)"
    }
    Write-Host "  $($h.IP) [$($h.Nome)]: $status$latency"
}

# 2. Teste MMS rapido nos gateways
Write-Host ""
Write-Host "=== 2. TESTE TCP 102 (MMS) NOS GATEWAYS ==="
foreach ($gw in @('172.16.176.206','172.16.176.208','172.16.176.209')) {
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $connect = $tcp.BeginConnect($gw, 102, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(2000, $false)
        if ($wait -and $tcp.Connected) {
            Write-Host "  $gw porta 102: ABERTA!"
        } else {
            Write-Host "  $gw porta 102: FECHADA/FILTERED"
        }
        $tcp.Close()
    } catch {
        Write-Host "  $gw porta 102: ERRO - $($_.Exception.Message)"
    }
}

# 3. Teste MMS em alguns reles
Write-Host ""
Write-Host "=== 3. TESTE TCP 102 (MMS) NOS RELES ==="
foreach ($rele in @('172.16.176.5','172.16.176.10','172.16.176.20','172.16.176.26')) {
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $connect = $tcp.BeginConnect($rele, 102, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(2000, $false)
        if ($wait -and $tcp.Connected) {
            Write-Host "  $rele porta 102: ABERTA"
        } else {
            Write-Host "  $rele porta 102: FECHADA"
        }
        $tcp.Close()
    } catch {
        Write-Host "  $rele porta 102: ERRO"
    }
}

# 4. ARP table atual
Write-Host ""
Write-Host "=== 4. TABELA ARP ATUAL ==="
arp -a -N 172.16.176.233
