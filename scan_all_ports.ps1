# Scan IEC 61850 ports on all 31 hosts - 172.16.176.0/24
$hosts = @(
    '172.16.176.1','172.16.176.2','172.16.176.3','172.16.176.4',
    '172.16.176.5','172.16.176.6','172.16.176.7','172.16.176.8',
    '172.16.176.9','172.16.176.10','172.16.176.11','172.16.176.12',
    '172.16.176.13','172.16.176.14','172.16.176.15','172.16.176.16',
    '172.16.176.17','172.16.176.19','172.16.176.20','172.16.176.21',
    '172.16.176.24','172.16.176.26','172.16.176.27','172.16.176.28',
    '172.16.176.30','172.16.176.31',
    '172.16.176.206','172.16.176.208','172.16.176.209',
    '172.16.176.217','172.16.176.220'
)

$ports = @(102, 80, 443, 502, 3721, 4840, 8080)
$results = @()

Write-Host "=== SCAN DE PORTAS IEC 61850 - $(Get-Date) ==="
Write-Host ""

foreach ($h in $hosts) {
    $line = "$h : "
    foreach ($p in $ports) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $connect = $tcp.BeginConnect($h, $p, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne(800, $false)
            if ($wait -and $tcp.Connected) {
                $line += "[$p ABERTA] "
                $results += [PSCustomObject]@{Host=$h; Port=$p; Status='ABERTA'}
            } else {
                $line += "$p- "
            }
            $tcp.Close()
        } catch {
            $line += "$p- "
        }
    }
    Write-Host $line
}

Write-Host ""
Write-Host "=== RESUMO - PORTAS ABERTAS ==="
$results | Format-Table -AutoSize
Write-Host "Total: $($results.Count) portas abertas"
