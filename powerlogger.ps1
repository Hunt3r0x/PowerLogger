param (
    [string]$LogFile = "C:\Users\Public\PowerLoggerPs\Usage_Logs.txt",
    [int]$Interval = 5
)

$logDir = [System.IO.Path]::GetDirectoryName($LogFile)
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir
}

$logRotationSize = 10MB

function Rotate-Log {
    param([string]$logFile)

    if ((Test-Path $logFile) -and ((Get-Item $logFile).length -gt $logRotationSize)) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Rename-Item $logFile "$logDir\usage_log-$timestamp.txt"
        Write-Host "Log file rotated: $logDir\usage_log-$timestamp.txt" -ForegroundColor Yellow
    }
}

function Write-LogHeader {
    param([string]$logFile)

    Add-Content $logFile "Timestamp, CPU(%), RAM(Used MB), RAM(Total MB), Disk(Used %), Network(Sent KB/s), Network(Received KB/s) `n"
}

function Print-ColoredOutput {
    param(
        [string]$timestamp, 
        [float]$cpu, 
        [float]$ramUsed, 
        [float]$ramTotal, 
        [float]$diskUsedPct, 
        [float]$netSent, 
        [float]$netReceived
    )

    Write-Host "--------------------------------------------" -ForegroundColor Gray
    Write-Host "Timestamp: " -ForegroundColor Yellow -NoNewline
    Write-Host "$timestamp" -ForegroundColor White

    Write-Host "CPU Usage: " -ForegroundColor Green -NoNewline
    Write-Host "$cpu %" -ForegroundColor White

    Write-Host "RAM Usage: " -ForegroundColor Cyan -NoNewline
    Write-Host "$ramUsed GB of $ramTotal GB" -ForegroundColor White

    Write-Host "Disk Usage: " -ForegroundColor Magenta -NoNewline
    Write-Host "$diskUsedPct %" -ForegroundColor White

    Write-Host "Network Sent: " -ForegroundColor Blue -NoNewline
    Write-Host "$netSent KB/s" -ForegroundColor White

    Write-Host "Network Received: " -ForegroundColor Blue -NoNewline
    Write-Host "$netReceived KB/s" -ForegroundColor White

    Write-Host "--------------------------------------------" -ForegroundColor Gray
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Power Logger - System Resource Monitor" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Logging system resource usage to: $LogFile" -ForegroundColor Green
Write-Host "Log file will be created if it does not exist." -ForegroundColor Green
Write-Host "Logging interval: $Interval seconds" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop logging." -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan

while ($true) {
    Rotate-Log -logFile $LogFile

    if (-not (Test-Path $LogFile)) {
        Write-LogHeader -logFile $LogFile
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $cpu = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average

    $ram = Get-WmiObject Win32_OperatingSystem
    $ramUsed = [math]::Round(($ram.TotalVisibleMemorySize - $ram.FreePhysicalMemory) / 1MB, 2)
    $ramTotal = [math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)

    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskUsedPct = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 2)

    $network = Get-Counter -Counter "\Network Interface(*)\Bytes Sent/sec","\Network Interface(*)\Bytes Received/sec"
    $netSent = [math]::Round($network.Countersamples[0].CookedValue / 1KB, 2)
    $netReceived = [math]::Round($network.Countersamples[1].CookedValue / 1KB, 2)

    Add-Content $LogFile "$timestamp, $cpu, $ramUsed, $ramTotal, $diskUsedPct, $netSent, $netReceived `n"

    Print-ColoredOutput -timestamp $timestamp -cpu $cpu -ramUsed $ramUsed -ramTotal $ramTotal -diskUsedPct $diskUsedPct -netSent $netSent -netReceived $netReceived

    Start-Sleep -Seconds $Interval
}