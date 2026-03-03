# Diagnostico e correcao do Dell .217 (GE Power Gateway)
Write-Host "=============================================="
Write-Host " DIAGNOSTICO GE POWER GATEWAY .217"
Write-Host " $(Get-Date)"
Write-Host "=============================================="

# 1. Tentar WinRM/PSRemoting
Write-Host ""
Write-Host "=== 1. TESTE WINRM (PSRemoting) ==="
try {
    Test-WSMan -ComputerName 172.16.176.217 -ErrorAction Stop
    Write-Host "WinRM DISPONIVEL!"
} catch {
    Write-Host "WinRM indisponivel: $($_.Exception.Message)"
}

# 2. Verificar RPC
Write-Host ""
Write-Host "=== 2. TESTE RPC (porta 135) ==="
$tcp = New-Object System.Net.Sockets.TcpClient
try {
    $tcp.Connect("172.16.176.217", 135)
    Write-Host "RPC porta 135: ABERTA"
    $tcp.Close()
} catch {
    Write-Host "RPC porta 135: FECHADA"
}

# 3. Verificar SMB
Write-Host ""
Write-Host "=== 3. TESTE SMB (porta 445) ==="
$tcp2 = New-Object System.Net.Sockets.TcpClient
try {
    $tcp2.Connect("172.16.176.217", 445)
    Write-Host "SMB porta 445: ABERTA"
    $tcp2.Close()

    Write-Host "Testando acesso SMB..."
    $shares = net view \\172.16.176.217 2>&1
    Write-Host $shares
} catch {
    Write-Host "SMB porta 445: FECHADA"
}

# 4. Verificar servico HASP/EGD via HTTP
Write-Host ""
Write-Host "=== 4. HASP LICENSE MANAGER (porta 1947) ==="
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert,
        WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
try {
    $hasp = Invoke-WebRequest -Uri 'http://172.16.176.217:1947' -TimeoutSec 10 -UseBasicParsing
    Write-Host "HASP Status: $($hasp.StatusCode)"
    $body = $hasp.Content
    if ($body.Length -gt 2000) { $body = $body.Substring(0, 2000) }
    Write-Host $body
} catch {
    Write-Host "HASP Erro: $($_.Exception.Message)"
}

# 5. Verificar pagina de erro HMI
Write-Host ""
Write-Host "=== 5. PAGINA DE ERRO HMI ==="
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    $hmi = Invoke-WebRequest -Uri 'https://172.16.176.217/' -TimeoutSec 15 -UseBasicParsing
    Write-Host "HMI Status: $($hmi.StatusCode)"
    Write-Host $hmi.Content
} catch {
    $resp = $_.Exception.Response
    if ($resp) {
        Write-Host "HMI Status: $([int]$resp.StatusCode) $($resp.StatusDescription)"
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errorBody = $reader.ReadToEnd()
        Write-Host "---ERROR BODY---"
        Write-Host $errorBody
    } else {
        Write-Host "Erro completo: $($_.Exception.Message)"
    }
}

# 6. Verificar OPC-UA
Write-Host ""
Write-Host "=== 6. OPC-UA (porta 4840) ==="
$tcp3 = New-Object System.Net.Sockets.TcpClient
try {
    $tcp3.Connect("172.16.176.217", 4840)
    Write-Host "OPC-UA porta 4840: ABERTA"
    # Send OPC-UA Hello
    $stream = $tcp3.GetStream()
    $stream.ReadTimeout = 5000
    # Read banner if any
    $buffer = New-Object byte[] 256
    try {
        $bytesRead = $stream.Read($buffer, 0, 256)
        Write-Host "Banner ($bytesRead bytes): $([System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead))"
    } catch {
        Write-Host "Sem banner (normal para OPC-UA)"
    }
    $tcp3.Close()
} catch {
    Write-Host "OPC-UA porta 4840: ERRO - $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== FIM DO DIAGNOSTICO ==="
