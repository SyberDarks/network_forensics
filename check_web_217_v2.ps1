# Bypass SSL certificate validation
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "=== HTTPS 172.16.176.217 ==="
try {
    $r = Invoke-WebRequest -Uri 'https://172.16.176.217' -TimeoutSec 15 -UseBasicParsing
    Write-Host "Status: $($r.StatusCode)"
    Write-Host "Server: $($r.Headers['Server'])"
    Write-Host "Content-Type: $($r.Headers['Content-Type'])"
    $body = $r.Content
    if ($body.Length -gt 4000) { $body = $body.Substring(0, 4000) }
    Write-Host "---BODY (primeiros 4000 chars)---"
    Write-Host $body
} catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.InnerException) {
        Write-Host "Inner: $($_.Exception.InnerException.Message)"
    }
}

Write-Host ""
Write-Host "=== HTTPS 172.16.150.216 ==="
try {
    $r2 = Invoke-WebRequest -Uri 'https://172.16.150.216' -TimeoutSec 15 -UseBasicParsing
    Write-Host "Status: $($r2.StatusCode)"
    Write-Host "Server: $($r2.Headers['Server'])"
    $body2 = $r2.Content
    if ($body2.Length -gt 4000) { $body2 = $body2.Substring(0, 4000) }
    Write-Host "---BODY---"
    Write-Host $body2
} catch {
    Write-Host "Erro: $($_.Exception.Message)"
}
