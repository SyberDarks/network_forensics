# NetSentinel - Analise Profunda GOOSE
# Os campos corretos do TShark para GOOSE sao verificados aqui

$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
$pcapFile   = "C:\Users\ricar\network-forensics-cli\iec61850_capture.pcap"

Write-Host "=== ANALISE GOOSE DETALHADA ===" -ForegroundColor Cyan
Write-Host ""

# Verificar campos GOOSE disponiveis
Write-Host "--- Campos GOOSE disponiveis no TShark ---" -ForegroundColor Yellow
& $tsharkPath -G fields 2>&1 | Select-String "^F.*goose" | Select-Object -First 30

Write-Host ""
Write-Host "--- Pacotes GOOSE com campos principais ---" -ForegroundColor Yellow

# Usar campos corretos do GOOSE IEC 61850
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e frame.number `
    -e frame.time_relative `
    -e eth.src `
    -e eth.dst `
    -e vlan.id `
    -e vlan.priority `
    -e goose.gocbRef `
    -e goose.stNum `
    -e goose.sqNum `
    -e goose.timeAllowedToLive `
    -e goose.numDatSetEntries `
    -E header=y `
    -E separator="|" `
    2>&1

Write-Host ""
Write-Host "--- Verificando flag de teste GOOSE ---" -ForegroundColor Yellow
# Tentar com o campo correto goose.t (test bit)
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e frame.number `
    -e goose.gocbRef `
    -e goose.stNum `
    -e goose.sqNum `
    -E header=y `
    -E separator="|" `
    2>&1 | Select-Object -First 25

Write-Host ""
Write-Host "--- Analise de stNum (mudancas de estado - eventos) ---" -ForegroundColor Yellow
Write-Host "stNum > 1 indica eventos reais ocorridos na subestacao:" -ForegroundColor Gray

$stNums = & $tsharkPath -r $pcapFile -Y "goose" -T fields -e goose.stNum 2>&1
$unique_stNums = $stNums | Sort-Object | Get-Unique
Write-Host "Valores unicos de stNum encontrados: $($unique_stNums -join ', ')" -ForegroundColor White

if ($stNums | Where-Object { [int]$_ -gt 1 }) {
    Write-Host "EVENTOS REAIS DETECTADOS: Multiplos valores de stNum indicam que os dispositivos" -ForegroundColor Yellow
    Write-Host "estao reportando mudancas de estado (trips de disjuntor, alarmes, etc.)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- Verificando anomalia: sqNum resetado (indicativo de reinicializacao) ---" -ForegroundColor Yellow
$sqNums = & $tsharkPath -r $pcapFile -Y "goose" -T fields -e frame.number -e goose.sqNum 2>&1
$sqNums

Write-Host ""
Write-Host "--- MAC OUI: 00:1A:D3 - Identificando fabricante ---" -ForegroundColor Yellow
Write-Host "Todos os pacotes GOOSE veem de MACs com OUI 00:1A:D3" -ForegroundColor White
Write-Host "Verificando via API..." -ForegroundColor Gray

Write-Host ""
Write-Host "--- VLAN e Prioridade (CoS) nos pacotes GOOSE ---" -ForegroundColor Yellow
Write-Host "IEC 61850-8-1 define: VLAN para segregacao, CoS=4 para GOOSE de alta prioridade" -ForegroundColor Gray
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e vlan.id `
    -e vlan.priority `
    -E header=y -E separator="|" 2>&1 | Sort-Object | Get-Unique

Write-Host ""
Write-Host "--- Taxa de transmissao GOOSE (intervalo entre pacotes) ---" -ForegroundColor Yellow
Write-Host "GOOSE normal: rapido apos evento (< 4ms), depois aumenta. Suspeito se sempre fixo:" -ForegroundColor Gray
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e frame.number `
    -e frame.time_relative `
    -e goose.stNum `
    -e goose.sqNum `
    -E separator="|" 2>&1

Write-Host ""
Write-Host "=== FIM DA ANALISE GOOSE ===" -ForegroundColor Cyan
