# NetSentinel - Captura de Trafego IEC 61850
# Interface 5 (Realtek - 172.16.176.233) por 30 segundos
# Filtro: GOOSE (0x88B8) | Sampled Values (0x88BA) | MMS TCP 102

$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
$outputPcap = "C:\Users\ricar\network-forensics-cli\iec61850_capture.pcap"
$interface  = "5"
$duration   = "30"

# Filtro BPF para IEC 61850: GOOSE, SV e MMS
# ether proto 0x88b8 = GOOSE
# ether proto 0x88ba = Sampled Values
# tcp port 102       = MMS/ISO-TSAP
$bpfFilter = "(ether proto 0x88b8) or (ether proto 0x88ba) or (tcp port 102)"

Write-Host ""
Write-Host "=== CAPTURA DE TRAFEGO IEC 61850 ===" -ForegroundColor Cyan
Write-Host "Data/Hora inicio: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "Interface: $interface (Realtek 172.16.176.233)" -ForegroundColor Gray
Write-Host "Duracao: $duration segundos" -ForegroundColor Gray
Write-Host "Filtro BPF: $bpfFilter" -ForegroundColor Gray
Write-Host "Arquivo de saida: $outputPcap" -ForegroundColor Gray
Write-Host ""
Write-Host "Iniciando captura... aguarde $duration segundos." -ForegroundColor Yellow

# Executar TShark
$args = @(
    "-i", $interface,
    "-a", "duration:$duration",
    "-f", $bpfFilter,
    "-w", $outputPcap,
    "-q"
)

try {
    $proc = Start-Process -FilePath $tsharkPath -ArgumentList $args -Wait -PassThru -NoNewWindow
    Write-Host ""
    Write-Host "Captura finalizada. Codigo de saida: $($proc.ExitCode)" -ForegroundColor Gray
} catch {
    Write-Host "ERRO ao executar TShark: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verificar resultado
if (Test-Path $outputPcap) {
    $fileInfo = Get-Item $outputPcap
    $sizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    Write-Host "Arquivo gerado: $outputPcap" -ForegroundColor Green
    Write-Host "Tamanho: $sizeKB KB" -ForegroundColor Green
    Write-Host "Data/Hora fim: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray

    if ($fileInfo.Length -le 24) {
        Write-Host ""
        Write-Host "ATENCAO: Arquivo muito pequeno (apenas header PCAP). Nenhum pacote capturado." -ForegroundColor Red
        Write-Host "Possivel causa: Nenhum trafego IEC 61850 ativo na interface $interface durante a captura." -ForegroundColor Yellow
    }
} else {
    Write-Host "ERRO: Arquivo de captura nao foi criado." -ForegroundColor Red
}
