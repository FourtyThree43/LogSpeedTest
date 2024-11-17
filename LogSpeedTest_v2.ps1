<#
.SYNOPSIS
  Script to run Speedtest and log results to CSV and TXT files with enhanced error handling and modular structure.

.DESCRIPTION
  This script runs Speedtest using the CLI, logs results in both CSV and TXT formats,
  supports auto-creation of directories, validates Speedtest CLI installation, rotates logs,
  and provides detailed logs and summaries.

.PARAMETERS
  CsvLogPath  - Path to the CSV log file (default: Logs\SpeedTestLog.csv in the script's directory)
  TxtLogPath  - Path to the TXT log file (default: Logs\SpeedTestErrorLog.txt in the script's directory)
  TestDelay   - Delay between tests in seconds (default: 10 seconds)

.NOTES
  Version:        0.5
  Author:         FourtyThree43
  Creation Date:  18.11.2024
  Purpose/Change: Initial version with error handling and logging.
#>

# Determine script and log paths
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logsPath = Join-Path $scriptPath "Logs"
$archivePath = Join-Path $logsPath "Archive"

# Parameters
param(
    [string]$CsvLogPath,
    [string]$TxtLogPath,
    [int]$TestDelay = 10  # Default delay if not provided
)

# Default paths for logs
if (-not $CsvLogPath) { $CsvLogPath = Join-Path $logsPath "SpeedTestLog.csv" }
if (-not $TxtLogPath) { $TxtLogPath = Join-Path $logsPath "SpeedTestErrorLog.txt" }

# Ensure necessary directories exist
if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force
    Write-Host "Logs directory created at $logsPath"
}

if (-not (Test-Path $archivePath)) {
    New-Item -ItemType Directory -Path $archivePath -Force
    Write-Host "Archive directory created at $archivePath"
}

# Function to write logs with timestamp
Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$message,
        [Parameter(Mandatory = $false)][ValidateSet("INFO", "WARN", "ERROR")][string]$level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    Add-Content -Path $TxtLogPath -Value "$timestamp [$level] - $message"
}

# Function to validate Speedtest CLI installation
Function Validate-SpeedtestCLI {
    if (-not (Get-Command speedtest -ErrorAction SilentlyContinue)) {
        Write-Log -message "Speedtest CLI not found. Please install it and ensure it's in the PATH." -level "ERROR"
        Write-Output "Speedtest CLI not found. Please install it before running the script."
        exit
    } else {
        Write-Log -message "Speedtest CLI found. Proceeding with tests."
    }
}

# Function to rotate logs if size exceeds limit
Function Rotate-Logs {
    param(
        [string]$logPath,
        [int]$maxSizeMB = 10  # Max size in MB before rotation
    )
    if (Test-Path $logPath) {
        $logFileSize = (Get-Item $logPath).Length / 1MB
        if ($logFileSize -gt $maxSizeMB) {
            $archiveLogPath = Join-Path $archivePath "$(Split-Path -Leaf $logPath).$((Get-Date).ToString('yyyyMMddHHmmss')).bak"
            Move-Item -Path $logPath -Destination $archiveLogPath
            Write-Log -message "Archived $logPath to $archiveLogPath due to size exceeding ${maxSizeMB}MB."
        }
    }
}

# Function to log Speedtest results
Function Log-SpeedTest {
    try {
        # Determine if CSV header is needed
        if (-not (Test-Path $CsvLogPath)) {
            $command = "speedtest --output-header --format=csv"
            Write-Log -message "CSV log file does not exist. Running Speedtest with headers."
        } else {
            $command = "speedtest --format=csv"
            Write-Log -message "CSV log file exists. Running Speedtest without headers."
        }

        # Run Speedtest
        $speedTestResult = Invoke-Expression $command
        $writer = New-Object System.IO.StreamWriter($CsvLogPath, $true)
        $writer.WriteLine($speedTestResult)
        $writer.Close()

        Write-Log -message "Speedtest results logged to CSV successfully."

        # Display summary in the console
        $speedTestOutput = $speedTestResult.Split(",")
        Write-Output "Speedtest completed. Summary of results:"
        Write-Output "Download Speed: $($speedTestOutput[6]) Mbps"
        Write-Output "Upload Speed: $($speedTestOutput[7]) Mbps"
        Write-Output "Ping: $($speedTestOutput[5]) ms"

    } catch {
        Write-Log -message "Failed to run Speedtest or write to CSV log: $_" -level "ERROR"
    }
}

# Main execution
Write-Log -message "######### Script Execution Started #########"
Validate-SpeedtestCLI
Rotate-Logs -logPath $CsvLogPath
Rotate-Logs -logPath $TxtLogPath

for ($i = 1; $i -le 3; $i++) {
    Write-Log -message "Starting Speedtest iteration $i."
    Log-SpeedTest
    if ($i -lt 3) {
        Write-Output "Waiting $TestDelay seconds before next test."
        Start-Sleep -Seconds $TestDelay
    }
}

Write-Log -message "######### Script Execution Completed #########"
Write-Output "Script execution complete. All tests completed successfully."
