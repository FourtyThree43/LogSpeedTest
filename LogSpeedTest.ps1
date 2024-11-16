# Define the path for the log file
$logFile = "Logs\Results.csv"

if (-not (Test-Path $logFile)) {
    "Timestamp,Server,ISP,Latency,Download (Mbps),Upload (Mbps),Packet Loss,Result URL" | Out-File -FilePath $logFile -Encoding UTF8
}

# Run the Speedtest CLI and capture the output in JSON format
$speedTestResult = speedtest --format=json | ConvertFrom-Json

# Extract details from the Speedtest output
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$server = $speedTestResult.server.name
$isp = $speedTestResult.isp
$latency = $speedTestResult.ping.latency
$downloadMbps = [math]::Round($speedTestResult.download.bandwidth / 125000, 2) # Convert from bytes/s to Mbps
$uploadMbps = [math]::Round($speedTestResult.upload.bandwidth / 125000, 2)   # Convert from bytes/s to Mbps
$packetLoss = $speedTestResult.packetLoss
$resultUrl = $speedTestResult.result.url

# Format the data as a CSV row
$logEntry = "$timestamp,$server,$isp,$latency,$downloadMbps,$uploadMbps,$packetLoss,$resultUrl"

# Append the result to the log file
$logEntry | Out-File -FilePath $logFile -Append -Encoding UTF8

# Output a message to confirm logging
Write-Host "Speedtest completed and logged to $logFile" -ForegroundColor Green
