# This script automates the download and execution of the Windows Update Tool (WUT) using PowerShell.

# Creating Banners and global variables

# Gets the current username for downloading and changing directory.
[string]$username = [System.Environment]::UserName

# Global variable for log file path
$logFilename = "C:\Users\$username\Downloads\" + (Get-Date -Format "yyyyMMdd_HHmmss_fff") + "_log.txt"

# Global variable for Download Path
[string]$DownloadPath = "C:\Users\$username\Downloads"

# Creating Functions

# Function to Write Log-Entries
# This function writes log entries with timestamps to a text file located at the global $logFilename.
function Write-Log {
    param([string]$logstring)
    $logEntry = "[" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff") + "] " + $logstring
    $logEntry | Out-File -FilePath $logFilename -Append
}



# Function to start the WUT.exe
# This function starts the WUT executable by changing the directory to the user's Downloads folder and executing the "WUT.exe" file.
function Start-Update {
    process {
    try {
            # Changing Directory to Downloads
            Write-Log "Changing Directory to $DownloadPath"
            Set-Location $DownloadPath
            # Executing Windows Update Tool
            Write-Log "Starting Update..."
            .\WUT.exe
    }
    catch {
        Write-Log "Error: File WUT.exe not found or path wrong, make sure WUT.exe exists in Download Folder"
        Write-Log "Current path to Download Folder: $DownloadPath - Is this true?"
        Exit
    }
    }
    
}

# Function to download WUT with BITS-Transfer
# This function downloads the WUT executable using the BITS-Transfer PowerShell module from "go.microsoft.com".
function Get-Update {
    process{
        try {
            Write-Log "WUT.exe doesnt exist in $DownloadPath"
            Import-Module BitsTransfer
            Write-Log "Waiting for Network to be configured..."
            Start-Sleep -Seconds 2
            Write-Log "Starting BitsTransfer Download from go.microsoft.com..."
            Start-BitsTransfer https://go.microsoft.com/fwlink/?LinkID=799445 "C:\Users\$username\Downloads\WUT.exe" -ErrorAction Stop
            Write-Log "Download Complete!"
        }
        catch {
            Write-Log 'Download failed, no Internet Connection available, or SSL Error because of incorrect System-Time'
            Exit
        }
    }
    
}

# This functio checks if the "WUT.exe" file already exists in the Downloads folder. If it does, the script logs that it exists and executes the Start-Update function to start the tool. If it does not exist, the script downloads the file using the Get-Update function and then executes the Start-Update function to start the tool.
function Test-WUT {
    Write-Log "Checking if WUT exists in Download Folder..."
    [bool]$WUTExists = Test-Path -Path "C:\Users\$username\Downloads\WUT.exe" -PathType Leaf
    if ($WUTExists -eq $true) {
        Write-Log "It exists!"
        Write-Log "Executing the Start-Update Function"
        Start-Update
        Exit
    }
}

# Checking if WUT already exist in Download Folder
Test-WUT
# Downloading and executing WUT if it didn't exist in Download Folder already
Get-Update
Start-Update
