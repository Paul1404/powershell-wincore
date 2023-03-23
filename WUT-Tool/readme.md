# Windows Update Tool (WUT) Automation Script

This PowerShell script automates the download and execution of the Windows Update Tool (WUT) by Microsoft. The script checks if the WUT executable file already exists in the user's Downloads folder. If it does, the script executes the Start-Update function to start the tool. If it does not exist, the script downloads the file using the Get-Update function and then executes the Start-Update function to start the tool.
Prerequisites

    PowerShell 5.1 or later
    BITS-Transfer PowerShell module

# Usage

    Download or copy the script to a location on your computer.
    Open PowerShell as an administrator.
    Navigate to the directory where the script is located.
    Run the script by typing .\update.ps1 and press Enter.

# Global Variables

## The following global variables are defined in the script:

    $username: Gets the current username for downloading and changing directory.
    $logFilename: Global variable for log file path.
    $DownloadPath: Global variable for download path.

## Functions


1. This function writes log entries with timestamps to a text file located at the global $logFilename.
```Write-Log```

2. This function starts the WUT executable by changing the directory to the user's Downloads folder and executing the WUT.exe file.
```Start-Update```

3. This function downloads the WUT executable using the BITS-Transfer PowerShell module from go.microsoft.com.
```Get-Update```

4. This function checks if the WUT.exe file already exists in the Downloads folder. If it does, the script logs that it exists and executes the Start-Update function to start the tool. If it does not exist, the script downloads the file using the Get-Update function and then executes the Start-Update function to start the tool.
```Test-WUT```

## License

This script is licensed under the MIT License.
