# Define the path for the log file
$logFile = "Logs\Foo2.csv"

# Check if the log file exists
if (-not (Test-Path $logFile)) {
    try {
        # Run the Speedtest CLI with header included
        $speedTestResult = speedtest --output-header --format=csv
        
        # Write the result to the new log file
        $speedTestResult | Out-File -FilePath $logFile -Encoding UTF8
        Write-Host "Log file created with header and initial entry at $logFile" -ForegroundColor Green
    } catch {
        Write-Host "Error creating log file or running Speedtest CLI: $_" -ForegroundColor Red
        exit 1
    }
} else {
    try {
        # Run the Speedtest CLI without the header
        $speedTestResult = speedtest --format=csv
        
        # Append the result to the existing log file
        $speedTestResult | Out-File -FilePath $logFile -Append -Encoding UTF8
        Write-Host "Speedtest result appended to log file at $logFile" -ForegroundColor Green
    } catch {
        Write-Host "Error running Speedtest CLI or writing to log file: $_" -ForegroundColor Red
        exit 1
    }
}
