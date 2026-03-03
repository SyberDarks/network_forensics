# Check RDP and additional services on Dell .217
Write-Host "=== RDP (3389) ==="
$tcp = New-Object System.Net.Sockets.TcpClient
try {
    $tcp.Connect("172.16.176.217", 3389)
    Write-Host "RDP porta 3389: ABERTA - VOCE PODE CONECTAR VIA REMOTE DESKTOP!"
    $tcp.Close()
} catch {
    Write-Host "RDP porta 3389: FECHADA"
}

Write-Host ""
Write-Host "=== SSH (22) ==="
$tcp2 = New-Object System.Net.Sockets.TcpClient
try {
    $tcp2.Connect("172.16.176.217", 22)
    Write-Host "SSH porta 22: ABERTA"
    $stream = $tcp2.GetStream()
    $stream.ReadTimeout = 3000
    $buf = New-Object byte[] 256
    try {
        $n = $stream.Read($buf, 0, 256)
        Write-Host "Banner: $([System.Text.Encoding]::ASCII.GetString($buf, 0, $n))"
    } catch {}
    $tcp2.Close()
} catch {
    Write-Host "SSH porta 22: FECHADA"
}

Write-Host ""
Write-Host "=== VNC (5900) ==="
$tcp3 = New-Object System.Net.Sockets.TcpClient
try {
    $tcp3.Connect("172.16.176.217", 5900)
    Write-Host "VNC porta 5900: ABERTA"
    $tcp3.Close()
} catch {
    Write-Host "VNC porta 5900: FECHADA"
}

Write-Host ""
Write-Host "=== Pagina HTTPS de erro - conteudo completo ==="
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll2 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert,
        WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Try different paths
$paths = @('/login', '/api', '/status', '/health', '/admin', '/config', '/_status')
foreach ($p in $paths) {
    try {
        $r = Invoke-WebRequest -Uri "https://172.16.176.217$p" -TimeoutSec 5 -UseBasicParsing
        Write-Host "GET $p -> $($r.StatusCode)"
        if ($r.Content.Length -gt 0 -and $r.Content.Length -lt 500) {
            Write-Host "  Body: $($r.Content)"
        }
    } catch {
        $resp = $_.Exception.Response
        if ($resp) {
            Write-Host "GET $p -> $([int]$resp.StatusCode) $($resp.StatusDescription)"
        } else {
            Write-Host "GET $p -> Erro: $($_.Exception.Message)"
        }
    }
}

# Try the HMI error page static file
Write-Host ""
Write-Host "=== Pagina de erro estatica ==="
try {
    $r2 = Invoke-WebRequest -Uri "https://172.16.176.217/error.html" -TimeoutSec 5 -UseBasicParsing
    Write-Host "Status: $($r2.StatusCode)"
    Write-Host $r2.Content
} catch {
    $resp2 = $_.Exception.Response
    if ($resp2) {
        $stream = $resp2.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $body = $reader.ReadToEnd()
        Write-Host "Status: $([int]$resp2.StatusCode)"
        if ($body.Length -gt 0) { Write-Host $body }
    }
}

Write-Host ""
Write-Host "=== Verificar nome do computador via NetBIOS ==="
nbtstat -a 172.16.176.217 2>&1
