# NetSentinel - Analise Detalhada do PCAP IEC 61850
# Verifica GOOSE, MMS, SV, anomalias e problemas

$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"
$pcapFile   = "C:\Users\ricar\network-forensics-cli\iec61850_capture.pcap"

Write-Host ""
Write-Host "=== ANALISE DETALHADA - IEC 61850 ===" -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host "Arquivo: $pcapFile" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $pcapFile)) {
    Write-Host "ERRO: Arquivo $pcapFile nao encontrado." -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------------
# 1. ESTATISTICAS GERAIS
# ----------------------------------------------------------------
Write-Host "--- [1] ESTATISTICAS GERAIS ---" -ForegroundColor Yellow
& $tsharkPath -r $pcapFile -q -z "io,stat,0" 2>&1

Write-Host ""
Write-Host "--- [2] HIERARQUIA DE PROTOCOLOS ---" -ForegroundColor Yellow
& $tsharkPath -r $pcapFile -q -z "io,phs" 2>&1

# ----------------------------------------------------------------
# 2. ANALISE GOOSE (EtherType 0x88B8)
# ----------------------------------------------------------------
Write-Host ""
Write-Host "--- [3] PACOTES GOOSE (EtherType 0x88B8) ---" -ForegroundColor Yellow
$gooseCount = & $tsharkPath -r $pcapFile -Y "goose" -q -z "io,stat,0" 2>&1
Write-Host "Contagem GOOSE:" -ForegroundColor Cyan
$gooseCount

Write-Host ""
Write-Host "Detalhes dos pacotes GOOSE (primeiros 15):" -ForegroundColor Cyan
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e frame.number `
    -e frame.time_relative `
    -e eth.src `
    -e eth.dst `
    -e vlan.id `
    -e goose.gocbRef `
    -e goose.stNum `
    -e goose.sqNum `
    -e goose.test `
    -e goose.numDatSetEntries `
    -E header=y `
    -E separator="," `
    -E quote=d `
    2>&1 | Select-Object -First 16

# ----------------------------------------------------------------
# 3. ANALISE MMS (TCP 102)
# ----------------------------------------------------------------
Write-Host ""
Write-Host "--- [4] PACOTES MMS (TCP porta 102) ---" -ForegroundColor Yellow
$mmsPackets = & $tsharkPath -r $pcapFile -Y "tcp.port==102" -q 2>&1
if ($LASTEXITCODE -eq 0) {
    $mmsCount = & $tsharkPath -r $pcapFile -Y "tcp.port==102" -T fields -e frame.number 2>&1
    if ($mmsCount) {
        Write-Host "MMS DETECTADO! Quantidade: $($mmsCount.Count) pacotes" -ForegroundColor Green
        & $tsharkPath -r $pcapFile -Y "tcp.port==102" -T fields `
            -e frame.number -e ip.src -e ip.dst -e tcp.flags -e frame.len `
            -E header=y -E separator="," 2>&1
    } else {
        Write-Host "Nenhum pacote MMS (TCP 102) detectado." -ForegroundColor Red
    }
}

# ----------------------------------------------------------------
# 4. ANALISE SAMPLED VALUES (EtherType 0x88BA)
# ----------------------------------------------------------------
Write-Host ""
Write-Host "--- [5] PACOTES SAMPLED VALUES (EtherType 0x88BA) ---" -ForegroundColor Yellow
$svFrames = & $tsharkPath -r $pcapFile -Y "sv" -T fields -e frame.number 2>&1
if ($svFrames) {
    Write-Host "Sampled Values DETECTADOS! Quantidade: $($svFrames.Count) pacotes" -ForegroundColor Green
} else {
    Write-Host "Nenhum pacote Sampled Values detectado." -ForegroundColor Red
}

# ----------------------------------------------------------------
# 5. ANALISE DE ANOMALIAS
# ----------------------------------------------------------------
Write-Host ""
Write-Host "--- [6] ANALISE DE ANOMALIAS ---" -ForegroundColor Yellow

# 5a. Pacotes malformados
Write-Host "Verificando pacotes malformados..." -ForegroundColor Cyan
$malformed = & $tsharkPath -r $pcapFile -Y "_ws.malformed" -T fields -e frame.number 2>&1
if ($malformed) {
    Write-Host "ALERTA: Pacotes malformados encontrados nos frames: $($malformed -join ', ')" -ForegroundColor Red
} else {
    Write-Host "Nenhum pacote malformado detectado." -ForegroundColor Green
}

# 5b. Retransmissoes TCP
Write-Host "Verificando retransmissoes TCP..." -ForegroundColor Cyan
$retrans = & $tsharkPath -r $pcapFile -Y "tcp.analysis.retransmission" -T fields -e frame.number 2>&1
if ($retrans) {
    Write-Host "ALERTA: Retransmissoes TCP nos frames: $($retrans -join ', ')" -ForegroundColor Red
} else {
    Write-Host "Nenhuma retransmissao TCP detectada." -ForegroundColor Green
}

# 5c. Verificar GOOSE com flag de teste ativo
Write-Host "Verificando pacotes GOOSE com flag TEST=True..." -ForegroundColor Cyan
$gooseTest = & $tsharkPath -r $pcapFile -Y "goose.test==1" -T fields -e frame.number -e goose.gocbRef 2>&1
if ($gooseTest) {
    Write-Host "ATENCAO: Pacotes GOOSE em modo TESTE encontrados (nao operacionais):" -ForegroundColor DarkYellow
    $gooseTest | ForEach-Object { Write-Host "  Frame: $_" -ForegroundColor Yellow }
} else {
    Write-Host "Nenhum GOOSE em modo teste. Mensagens sao OPERACIONAIS." -ForegroundColor Green
}

# 5d. Analise de VLAN nos pacotes GOOSE
Write-Host "Verificando VLAN nos pacotes GOOSE..." -ForegroundColor Cyan
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e vlan.id -e vlan.priority `
    -E header=y -E separator="," 2>&1 | Sort-Object | Get-Unique | Select-Object -First 10

# 5e. Analise de stNum (mudancas de estado GOOSE - eventos de subestacao)
Write-Host ""
Write-Host "--- [7] ANALISE DE MUDANCAS DE ESTADO GOOSE (stNum) ---" -ForegroundColor Yellow
Write-Host "stNum incrementa quando ha evento real (trip de disjuntor, alarme, etc.):" -ForegroundColor Gray
& $tsharkPath -r $pcapFile -Y "goose" -T fields `
    -e frame.number `
    -e frame.time_relative `
    -e goose.stNum `
    -e goose.sqNum `
    -E header=y -E separator="," 2>&1 | Select-Object -First 20

# 5f. Estatisticas de IPs unicos (para MMS/TCP)
Write-Host ""
Write-Host "--- [8] CONVERSAS IP (se houver MMS) ---" -ForegroundColor Yellow
& $tsharkPath -r $pcapFile -q -z "conv,ip" 2>&1

# 5g. Lista de enderecos MAC unicos
Write-Host ""
Write-Host "--- [9] ENDERECOS MAC OBSERVADOS NA CAPTURA ---" -ForegroundColor Yellow
& $tsharkPath -r $pcapFile -T fields -e eth.src 2>&1 | Sort-Object | Get-Unique

Write-Host ""
Write-Host "=== ANALISE CONCLUIDA ===" -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
