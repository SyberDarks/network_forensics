# Scan de portas IEC 61850 na rede 172.16.176.0/24
Write-Host "=== SCAN TCP 102 (MMS) em todos os hosts ==="
$hosts = @('172.16.176.20','172.16.176.205','172.16.176.206','172.16.176.207','172.16.176.208','172.16.176.209')
foreach ($h in $hosts) {
    $result = Test-NetConnection -ComputerName $h -Port 102 -WarningAction SilentlyContinue
    Write-Host "$h - TCP 102 (MMS): $($result.TcpTestSucceeded)"
}

Write-Host ""
Write-Host "=== SCAN PORTAS COMPLETO no IED Vamp 172.16.176.20 ==="
$ports = @(21,22,23,80,102,161,443,502,3721,4840,8080,8443)
foreach ($p in $ports) {
    $result = Test-NetConnection -ComputerName '172.16.176.20' -Port $p -WarningAction SilentlyContinue
    $status = if ($result.TcpTestSucceeded) { "ABERTA" } else { "fechada" }
    Write-Host "  Porta $p : $status"
}

Write-Host ""
Write-Host "=== SCAN PORTAS nos gateways Advantech ==="
$advHosts = @('172.16.176.205','172.16.176.207')
foreach ($h in $advHosts) {
    Write-Host "--- $h ---"
    foreach ($p in @(80,102,443,502,3721,4840,8080)) {
        $result = Test-NetConnection -ComputerName $h -Port $p -WarningAction SilentlyContinue
        $status = if ($result.TcpTestSucceeded) { "ABERTA" } else { "fechada" }
        Write-Host "  Porta $p : $status"
    }
}
