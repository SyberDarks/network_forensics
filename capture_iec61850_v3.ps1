# NetSentinel - Captura de Trafego IEC 61850 v3
# Interface CORRETA: 10 = Ethernet (Realtek PCIe GbE - 172.16.176.233)
# Interface 5 no TShark = Bluetooth (ERRADA)
# Interface 10 no TShark = Ethernet Realtek (CORRETA)

$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
$outputPcap = "C:\Users\ricar\network-forensics-cli\iec61850_capture.pcap"
$interface  = "10"   # TShark #10 = "Ethernet" = Realtek = 172.16.176.233
$duration   = "30"

Write-Host ""
Write-Host "=== CAPTURA DE TRAFEGO IEC 61850 ===" -ForegroundColor Cyan
Write-Host "Data/Hora inicio: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "Interface TShark #10: Ethernet (Realtek PCIe GbE)" -ForegroundColor Gray
Write-Host "IP local: 172.16.176.233" -ForegroundColor Gray
Write-Host "Duracao: $duration segundos" -ForegroundColor Gray
Write-Host "Filtro BPF: GOOSE(0x88B8) | SV(0x88BA) | MMS(TCP 102)" -ForegroundColor Gray
Write-Host "Arquivo de saida: $outputPcap" -ForegroundColor Gray
Write-Host ""
Write-Host "Iniciando captura... aguarde $duration segundos." -ForegroundColor Yellow

# Remover pcap anterior se existir
if (Test-Path $outputPcap) {
    Remove-Item $outputPcap -Force
    Write-Host "Arquivo anterior removido." -ForegroundColor Gray
}

# Executar TShark na interface correta
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

    if ($fileInfo.Length -le 25) {
        Write-Host ""
        Write-Host "ATENCAO: Arquivo muito pequeno (apenas header PCAP). Zero pacotes capturados." -ForegroundColor Red
        Write-Host "Possivel causa: Sem trafego IEC 61850 ativo neste momento." -ForegroundColor Yellow
    } else {
        Write-Host "Pacotes capturados! Prosseguindo com analise." -ForegroundColor Green

        # Contar pacotes
        Write-Host ""
        Write-Host "=== CONTAGEM DE PACOTES ===" -ForegroundColor Cyan
        & $tsharkPath -r $outputPcap -q -z "io,phs" 2>&1
    }
} else {
    Write-Host "ERRO: Arquivo de captura nao foi criado." -ForegroundColor Red
}
