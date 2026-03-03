$tshark = "C:\Program Files\Wireshark\tshark.exe"
$pcap = "C:\Users\ricar\network-forensics-cli\captura_pos_desligamento.pcap"

Write-Host "=== TRAFEGO DO DISPOSITIVO .240 (HP b0:0c:d1:5a:01:50) ==="
& $tshark -r $pcap -Y "eth.src==b0:0c:d1:5a:01:50 or eth.dst==b0:0c:d1:5a:01:50 or ip.addr==172.16.176.240" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e ip.src -e ip.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null

Write-Host ""
Write-Host "=== CONTAGEM DE PACOTES .240 ==="
$count = (& $tshark -r $pcap -Y "eth.src==b0:0c:d1:5a:01:50 or eth.dst==b0:0c:d1:5a:01:50 or ip.addr==172.16.176.240" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
Write-Host "Total pacotes: $count"

Write-Host ""
Write-Host "=== VERIFICANDO NO PCAP ANTES (FULL) ==="
$pcap_antes = "C:\Users\ricar\network-forensics-cli\full_capture_61850.pcap"
& $tshark -r $pcap_antes -Y "eth.src==b0:0c:d1:5a:01:50 or eth.dst==b0:0c:d1:5a:01:50 or ip.addr==172.16.176.240" -T fields -e frame.number -e frame.time_relative -e eth.src -e eth.dst -e ip.src -e ip.dst -e _ws.col.Protocol -e _ws.col.Info 2>$null

$count2 = (& $tshark -r $pcap_antes -Y "eth.src==b0:0c:d1:5a:01:50 or eth.dst==b0:0c:d1:5a:01:50 or ip.addr==172.16.176.240" -T fields -e frame.number 2>$null | Measure-Object -Line).Lines
Write-Host "Total pacotes ANTES: $count2"
