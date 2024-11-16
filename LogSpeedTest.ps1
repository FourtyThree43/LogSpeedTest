# Define the path for the log files
$logFile = "Logs\Results.csv"
$logFile2 = "Logs\Foo.json"

# Ensure Logs directory exists
if (-not (Test-Path "Logs")) {
    New-Item -ItemType Directory -Path "Logs"
}

# Create CSV log file with headers if it doesn't exist
if (-not (Test-Path $logFile)) {
    "Timestamp,Server,ISP,Latency,Download (Mbps),Upload (Mbps),Packet Loss,Result URL" | Out-File -FilePath $logFile -Encoding UTF8
}

# Run the Speedtest CLI and write raw JSON output directly to the log file
try {
    $speedTestRawOutput = speedtest --format=json
    $speedTestRawOutput | Out-File -FilePath $logFile2 -Append -Encoding UTF8
} catch {
    Write-Host "Speedtest failed to execute. Check your network or the Speedtest CLI." -ForegroundColor Red
    exit 1
}

# Parse the JSON output for extracting specific details
$speedTestResult = $speedTestRawOutput | ConvertFrom-Json

# Validate Speedtest result
if (-not $speedTestResult -or -not $speedTestResult.server) {
    Write-Host "Invalid Speedtest result. Check $logFile2 for details." -ForegroundColor Yellow
    exit 1
}

# Extract details from the Speedtest output
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$server = $speedTestResult.server.name
$isp = $speedTestResult.isp
$latency = $speedTestResult.ping.latency
# Convert from bytes/s to Mbps
$downloadMbps = [math]::Round($speedTestResult.download.bandwidth / 125000, 2) 
$uploadMbps = [math]::Round($speedTestResult.upload.bandwidth / 125000, 2)
$packetLoss = $speedTestResult.packetLoss
$resultUrl = $speedTestResult.result.url

# Format the data as a CSV row
if ($server -and $isp -and $latency -and $downloadMbps -and $uploadMbps) {
    $logEntry = "$timestamp,$server,$isp,$latency,$downloadMbps,$uploadMbps,$packetLoss,$resultUrl"
    $logEntry | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host "Speedtest completed and logged to $logFile" -ForegroundColor Green
} else {
    Write-Host "Incomplete data from Speedtest. Check $logFile2 for raw results." -ForegroundColor Yellow
}
