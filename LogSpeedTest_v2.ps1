<#
.SYNOPSIS
  Logs internet speed test results in CSV format.

.DESCRIPTION
  This script uses the Speedtest CLI to log download, upload, and ping results to a CSV file.
  If the log file does not exist, it includes headers. Otherwise, it appends new results.

.OUTPUTS
  Creates or updates a CSV log file with speed test results.

.NOTES
  Version:        0.4
  Author:         FourtyThree43
  Creation Date:  18.11.2024
  Purpose/Change: Initial version with error handling and logging.
#>

# Configuration
$logFile = "Logs\SpeedTestLog.csv"
$logErrorFile = "Logs\SpeedTestErrorLog.txt"

# Function to write logs with timestamp
Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO", "WARN", "ERROR")][string] $level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    Add-Content -Path $logErrorFile -Value "$timestamp [$level] - $message"
}

# Function to run Speedtest and log results
Function Log-SpeedTest {
    try {
        # Determine the Speedtest command based on log file existence
        if (-not (Test-Path $logFile)) {
            $command = "speedtest --output-header --format=csv"
            Write-Log -message "Log file does not exist. Running Speedtest with header."
        } else {
            $command = "speedtest --format=csv"
            Write-Log -message "Log file exists. Running Speedtest without header."
        }

        # Run the Speedtest CLI command
        $speedTestResult = Invoke-Expression $command
        
        # Write results to log file
        $speedTestResult | Out-File -FilePath $logFile -Append -Encoding UTF8
        Write-Log -message "Speedtest results logged successfully to $logFile."
    } catch {
        Write-Log -message "Failed to run Speedtest or write to log: $_" -level "ERROR"
    }
}

# Script Execution
Write-Log -message "######### Script Execution Started #########"
Log-SpeedTest
Write-Log -message "######### Script Execution Completed #########"
Write-Output "Speedtest logging completed. Check logs at $logFile and errors at $logErrorFile."
