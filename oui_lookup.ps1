# Script de lookup OUI para identificacao de fabricantes
# NetSentinel - Identificacao de Fabricantes IEC 61850

$oui_database = @{
    "00190F" = "Sagemcom Broadband SAS"
    "74FE48" = "AzureWave Technology Inc."
    "CC827F" = "Cisco Systems, Inc."
    "C400AD" = "Nokia Solutions and Networks GmbH & Co. KG"
}

# MACs dos dispositivos na rede 172.16.176.0/24
$devices = @(
    @{ IP = "172.16.176.205"; MAC = "00-19-0F-3B-6E-B7" },
    @{ IP = "172.16.176.206"; MAC = "00-19-0F-3C-64-AC" },
    @{ IP = "172.16.176.207"; MAC = "74-FE-48-93-D4-24" },
    @{ IP = "172.16.176.208"; MAC = "CC-82-7F-60-2E-28" },
    @{ IP = "172.16.176.209"; MAC = "C4-00-AD-ED-FF-78" }
)

Write-Host "`n=== IDENTIFICACAO DE FABRICANTES VIA OUI ===" -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "Rede: 172.16.176.0/24`n" -ForegroundColor Gray

foreach ($device in $devices) {
    $mac = $device.MAC
    $oui = $mac.Replace("-","").Substring(0,6).ToUpper()
    $fabricante = $oui_database[$oui]
    if (-not $fabricante) {
        $fabricante = "Fabricante nao identificado localmente (OUI: $oui)"
    }
    Write-Host "IP: $($device.IP)" -ForegroundColor Yellow
    Write-Host "  MAC: $mac" -ForegroundColor White
    Write-Host "  OUI: $oui" -ForegroundColor White
    Write-Host "  Fabricante: $fabricante" -ForegroundColor Green
    Write-Host ""
}
