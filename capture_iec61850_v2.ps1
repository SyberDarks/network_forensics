# NetSentinel - Captura de Trafego IEC 61850 v2
# Interface 5 (Realtek - 172.16.176.233) por 30 segundos

$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
$outputPcap = "C:\Users\ricar\network-forensics-cli\iec61850_capture.pcap"
$interface  = "5"
$duration   = "30"

Write-Host ""
Write-Host "=== CAPTURA DE TRAFEGO IEC 61850 ===" -ForegroundColor Cyan
Write-Host "Data/Hora inicio: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "Interface: $interface (Realtek 172.16.176.233)" -ForegroundColor Gray
Write-Host "Duracao: $duration segundos" -ForegroundColor Gray
Write-Host "Arquivo de saida: $outputPcap" -ForegroundColor Gray
Write-Host ""
Write-Host "Iniciando captura... aguarde $duration segundos." -ForegroundColor Yellow

# Usar array de argumentos sem aspas extras nos filtros complexos
# O filtro BPF precisa ser passado como string unica sem subdivisao
& $tsharkPath -i $interface -a "duration:$duration" -f "(ether proto 0x88b8) or (ether proto 0x88ba) or (tcp port 102)" -w $outputPcap -q 2>&1

$exitCode = $LASTEXITCODE
Write-Host ""
Write-Host "Captura finalizada. Codigo de saida: $exitCode" -ForegroundColor Gray

# Verificar resultado
if (Test-Path $outputPcap) {
    $fileInfo = Get-Item $outputPcap
    $sizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    Write-Host "Arquivo gerado: $outputPcap" -ForegroundColor Green
    Write-Host "Tamanho: $sizeKB KB" -ForegroundColor Green
    Write-Host "Data/Hora fim: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray

    if ($fileInfo.Length -le 24) {
        Write-Host ""
        Write-Host "ATENCAO: Arquivo muito pequeno (apenas header PCAP). Nenhum pacote IEC 61850 capturado." -ForegroundColor Red
        Write-Host "Possivel causa: Trafego IEC 61850 nao ativo neste momento ou filtragem errada." -ForegroundColor Yellow
    }
} else {
    Write-Host "ERRO: Arquivo de captura nao foi criado." -ForegroundColor Red
}
