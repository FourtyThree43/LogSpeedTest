<#
.SYNOPSIS
  Logs internet speed test results in CSV format and maintains a separate log for informational and error messages.

.DESCRIPTION
  This script uses the Speedtest CLI to log download, upload, and ping results to a CSV file.
  It also writes informational and error logs to a TXT log file.

.OUTPUTS
  - A CSV log file for speed test results.
  - A TXT log file for informational and error messages.

.NOTES
  Version:        0.4
  Author:         FourtyThree43
  Creation Date:  18.11.2024
  Purpose/Change: Initial version with error handling and logging.
#>

# Configuration
$resultsLogFile = "Logs\SpeedTestLog.csv"
$txtLogFile = "Logs\SpeedTestErrorLog.txt"

# Function to write logs with timestamp
Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO", "WARN", "ERROR")][string] $level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    Add-Content -Path $txtLogFile -Value "$timestamp [$level] - $message"
}

# Function to run Speedtest and log results to CSV
Function Log-SpeedTest {
    try {
        # Determine the Speedtest command based on the existence of the CSV log file
        if (-not (Test-Path $resultsLogFile)) {
            $command = "speedtest --output-header --format=csv"
            Write-Log -message "CSV log file does not exist. Running Speedtest with headers."
        } else {
            $command = "speedtest --format=csv"
            Write-Log -message "CSV log file exists. Running Speedtest without headers."
        }

        # Run the Speedtest CLI command and capture output
        $speedTestResult = Invoke-Expression $command
        
        # Append results to the CSV log file
        $speedTestResult | Out-File -FilePath $resultsLogFile -Append -Encoding UTF8
        Write-Log -message "Speedtest results logged to CSV successfully."
    } catch {
        Write-Log -message "Failed to run Speedtest or write to CSV log: $_" -level "ERROR"
    }
}

# Script Execution
Write-Log -message "######### Script Execution Started #########"
Log-SpeedTest
Write-Log -message "######### Script Execution Completed #########"
Write-Output "Speedtest logging completed. Check CSV results at $resultsLogFile and logs at $txtLogFile."
