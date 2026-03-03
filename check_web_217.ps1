# Check web interface on Dell .217
Write-Host "=== Tentando HTTPS 172.16.176.217 ==="
try {
    $r = Invoke-WebRequest -Uri 'https://172.16.176.217' -TimeoutSec 10 -UseBasicParsing -SkipCertificateCheck
    Write-Host "Status: $($r.StatusCode)"
    Write-Host "Server: $($r.Headers['Server'])"
    Write-Host "Content-Type: $($r.Headers['Content-Type'])"
    Write-Host "---BODY---"
    Write-Host $r.Content.Substring(0, [Math]::Min(3000, $r.Content.Length))
} catch {
    Write-Host "HTTPS Erro: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== Tentando HTTP 172.16.176.217 ==="
try {
    $r2 = Invoke-WebRequest -Uri 'http://172.16.176.217' -TimeoutSec 10 -UseBasicParsing
    Write-Host "Status: $($r2.StatusCode)"
    Write-Host "Server: $($r2.Headers['Server'])"
    Write-Host "---BODY---"
    Write-Host $r2.Content.Substring(0, [Math]::Min(3000, $r2.Content.Length))
} catch {
    Write-Host "HTTP Erro: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== Tentando HTTPS 172.16.150.216 ==="
try {
    $r3 = Invoke-WebRequest -Uri 'https://172.16.150.216' -TimeoutSec 10 -UseBasicParsing -SkipCertificateCheck
    Write-Host "Status: $($r3.StatusCode)"
    Write-Host "Server: $($r3.Headers['Server'])"
    Write-Host "---BODY---"
    Write-Host $r3.Content.Substring(0, [Math]::Min(3000, $r3.Content.Length))
} catch {
    Write-Host "HTTPS 150.216 Erro: $($_.Exception.Message)"
}
