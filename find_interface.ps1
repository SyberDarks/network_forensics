# Identificar interface Realtek com IP 172.16.176.x
Write-Host "=== IPs configurados na maquina ===" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "172.16.*" -or $_.IPAddress -like "10.*" } | Select-Object IPAddress, InterfaceIndex, InterfaceAlias | Format-Table -AutoSize

Write-Host "=== Todos os adaptadores de rede ===" -ForegroundColor Cyan
Get-NetAdapter | Select-Object Name, InterfaceDescription, InterfaceIndex, Status, LinkSpeed | Format-Table -AutoSize

Write-Host "=== Rotas para 172.16.176.0/24 ===" -ForegroundColor Cyan
Get-NetRoute | Where-Object { $_.DestinationPrefix -like "172.16.176*" } | Format-Table -AutoSize
