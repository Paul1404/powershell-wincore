# Windows Update Tool Script

This script is designed to automate the process of downloading and running the Windows Update Tool (WUT). The script has been designed to check the existence of the WUT executable file in the user's Downloads folder and download it using BITS-Transfer if it does not exist. The script also has a function to check and synchronize the system time if SSL errors are encountered during the download process.
Getting Started
Prerequisites

This script requires PowerShell version 5.1 or higher to run. It also requires the BitsTransfer module to download the WUT using BITS-Transfer.
Running the Script

To run the script, save it with a .ps1 extension and execute it from PowerShell by running the following command:

```
.\WindowsUpdateTool.ps1
```

## 1. Banners
When you execute the script, you will see two banners displayed before and after the execution of the script. The Start Banner shows the name of the script in ASCII art, while the End Banner shows the same name but in a different ASCII art.

## 2. Functions

- Start-Update
This function changes the directory to the Downloads folder, where the WUT executable is supposed to be saved. It then executes the WUT, which initiates the update process.

- Get-Update
This function downloads the WUT from the Microsoft website using BITS-Transfer. It checks for a valid internet connection and SSL errors during the download process. If the internet connection is not available or SSL errors occur, the function will call the Sync-Time function to check and synchronize the system time.

- Sync-Time
This function checks the system time and prompts the user to confirm if the time is correct. If the user responds negatively, the function synchronizes the system time using the Windows Time service.

## 3. Conclusion
This script automates the process of updating Windows by downloading and running the Windows Update Tool. The script can handle issues such as missing WUT executable file and SSL errors. It also displays ASCII art banners at the start and end of the script execution.
