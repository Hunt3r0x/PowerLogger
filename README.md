# PowerLogger

PowerLogger is a PowerShell script that monitors and logs CPU, RAM, disk, and network usage on your Windows system. It provides a clear and colorful terminal interface for easy monitoring and saves the logs to a specified file.

## Features

- Logs CPU usage percentage.
- Logs RAM usage (used and total).
- Logs disk usage percentage for the C: drive.
- Logs network usage (sent and received in KB/s).
- Customizable log file location and logging interval.

## Prerequisites

- Windows operating system with PowerShell.

## Installation

1. Download the `powerlogger.ps1` script.
2. Place the script in your desired directory.

## Usage

To run the script, use the following command in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File "path\to\powerlogger.ps1" -LogFile "C:\path\to\logs\usage_log.txt" -Interval 5
```

### Parameters

- `-LogFile`: Specifies the path and name of the log file. Default is `C:\Users\User\Documents\logs\Usage.txt`.
  
- `-Interval`: Specifies the interval (in seconds) for logging system resource usage. Default is `5` seconds.

## Example

To log CPU, RAM, disk, and network usage every 10 seconds and save it to a custom log file:

```powershell
powershell -ExecutionPolicy Bypass -File "path\to\powerlogger.ps1" -LogFile "C:\CustomDirectory\custom_log.txt" -Interval 10
```

## Notes

- The script will create the specified log directory if it doesn't already exist.
- The log file will be rotated if it exceeds 10 MB in size.
- Press `Ctrl+C` in the terminal to stop logging.