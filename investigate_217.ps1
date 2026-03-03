# Investigacao profunda do Dell .217
Write-Host "=============================================="
Write-Host " INVESTIGACAO DELL .217 - $(Get-Date)"
Write-Host "=============================================="

# 1. Nmap full scan - OS detection + all common ports
Write-Host ""
Write-Host "=== 1. NMAP COMPLETO COM OS DETECTION ==="
nmap -sV -O -A --send-eth -e eth1 -p 1-1024,1947,3721,4840,8080,8443,18246 172.16.176.217 2>&1

Write-Host ""
Write-Host "=== 2. NMAP SCRIPT SCAN (HTTP/MMS) ==="
nmap --script=http-title,http-headers,http-server-header --send-eth -e eth1 -p 80,443 172.16.176.217 2>&1

Write-Host ""
Write-Host "=== 3. VERIFICAR PORTA 18246 (EGD) ==="
nmap -sU --send-eth -e eth1 -p 18246,1947 172.16.176.217 2>&1

Write-Host ""
Write-Host "=== 4. TRACEROUTE PARA .217 ==="
tracert -d -w 1000 -h 5 172.16.176.217 2>&1

Write-Host ""
Write-Host "=== 5. NMAP TODOS OS IPS DO DELL ==="
nmap -sV --send-eth -e eth1 -p 80,102,443,4840,18246 172.16.150.216 2>&1

Write-Host "=== FIM ==="
