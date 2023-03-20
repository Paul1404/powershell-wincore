# Creating Banners and global variables

$empty_line = ""

$StartBanner = @"
:::       ::: :::    ::: :::::::::::       ::::::::   ::::::::  :::::::::  ::::::::::: ::::::::: :::::::::::      :::     :::      :::        :::::::  
:+:       :+: :+:    :+:     :+:          :+:    :+: :+:    :+: :+:    :+:     :+:     :+:    :+:    :+:          :+:     :+:    :+:+:       :+:   :+: 
+:+       +:+ +:+    +:+     +:+          +:+        +:+        +:+    +:+     +:+     +:+    +:+    +:+          +:+     +:+      +:+       +:+  :+:+ 
+#+  +:+  +#+ +#+    +:+     +#+          +#++:++#++ +#+        +#++:++#:      +#+     +#++:++#+     +#+          +#+     +:+      +#+       +#+ + +:+ 
+#+ +#+#+ +#+ +#+    +#+     +#+                 +#+ +#+        +#+    +#+     +#+     +#+           +#+           +#+   +#+       +#+       +#+#  +#+ 
 #+#+# #+#+#  #+#    #+#     #+#          #+#    #+# #+#    #+# #+#    #+#     #+#     #+#           #+#            #+#+#+#  #+#   #+#   #+# #+#   #+# 
  ###   ###    ########      ###           ########   ########  ###    ### ########### ###           ###              ###    ### ####### ###  #######  
"@

$EndBanner = @"
 ::::::::   ::::::::  ::::    ::::  :::::::::  :::        :::::::::: ::::::::::: :::::::::: :::::::::           :::    :::     :::     :::     ::: ::::::::::          :::          ::::    ::: ::::::::::: ::::::::  ::::::::::      :::::::::      :::   :::   ::: ::: 
:+:    :+: :+:    :+: +:+:+: :+:+:+ :+:    :+: :+:        :+:            :+:     :+:        :+:    :+:          :+:    :+:   :+: :+:   :+:     :+: :+:               :+: :+:        :+:+:   :+:     :+:    :+:    :+: :+:             :+:    :+:   :+: :+: :+:   :+: :+: 
+:+        +:+    +:+ +:+ +:+:+ +:+ +:+    +:+ +:+        +:+            +:+     +:+        +:+    +:+          +:+    +:+  +:+   +:+  +:+     +:+ +:+              +:+   +:+       :+:+:+  +:+     +:+    +:+        +:+             +:+    +:+  +:+   +:+ +:+ +:+  +:+ 
+#+        +#+    +:+ +#+  +:+  +#+ +#++:++#+  +#+        +#++:++#       +#+     +#++:++#   +#+    +:+          +#++:++#++ +#++:++#++: +#+     +:+ +#++:++#        +#++:++#++:      +#+ +:+ +#+     +#+    +#+        +#++:++#        +#+    +:+ +#++:++#++: +#++:   +#+ 
+#+        +#+    +#+ +#+       +#+ +#+        +#+        +#+            +#+     +#+        +#+    +#+          +#+    +#+ +#+     +#+  +#+   +#+  +#+             +#+     +#+      +#+  +#+#+#     +#+    +#+        +#+             +#+    +#+ +#+     +#+  +#+    +#+ 
#+#    #+# #+#    #+# #+#       #+# #+#        #+#        #+#            #+#     #+#        #+#    #+# #+#      #+#    #+# #+#     #+#   #+#+#+#   #+#             #+#     #+#      #+#   #+#+#     #+#    #+#    #+# #+#             #+#    #+# #+#     #+#  #+#        
 ########   ########  ###       ### ###        ########## ##########     ###     ########## #########  ##       ###    ### ###     ###     ###     ##########      ###     ###      ###    #### ########### ########  ##########      #########  ###     ###  ###    ### 
"@

Write-Output $empty_line
Write-Host "$StartBanner"
Start-Sleep -Seconds 2
Write-Output $empty_line
Write-Host "Welcome!"
Start-Sleep -Seconds 2
Write-Output $empty_line

# Creating Functions
# Function to start the WUT.exe
function Start-Update {
    process {
    try {
            # Changing Directory to Downloads
            [string]$DownloadPath = "C:\Users\$username\Downloads"
            Write-Host "Changing Directory..."
            Set-Location $DownloadPath
            # Executing Windows Update Tool
            Write-Host "Starting Update..."
            .\Update.exe
    }
    catch {
        Write-Host "Error: File Update.exe not found or path wrong, make sure Update.exe exists in Download Folder"
        Write-Host "Current path to Download Folder: $DownloadPath - Is this true?"
        Exit
    }
    }
    
}
# Function to download WUT with BITS-Transfer
function Get-Update {
    process{
        try {
            Import-Module BitsTransfer
            Write-Host "Waiting for Network to be configured..."
            Start-Sleep -Seconds 2
            Start-BitsTransfer https://go.microsoft.com/fwlink/?LinkID=799445 "C:\Users\$username\Downloads\Update.exe" -ErrorAction Stop
            Write-Host "Download Complete!"
        }
        catch {
            Write-Host 'Download failed, no Internet Connection available, or SSL Error because of incorrect System-Time'
            Sync-Time
            Exit
        }
    }
    
}

# Function to update System Time, resolving SSL Errors
function Sync-Time {
    process {
        $CurrentTime = (get-date).ToString('T')
        Write-Host "Current System-Time: $CurrentTime"
        [string]$TimeCorrect = Read-Host "Is your System-Time correct? (Y/N)"
            if ($TimeCorrect -eq "N") {
                Sync-WindowsTime
            } else {
                Exit
            }
    }
}

# Function to synchronize Windows System-Time
function Sync-WindowsTime {
    # Requires administrator rights
    # Check if the PowerShell session is elevated (has been run as an administrator)
    If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator") -eq $false) {
        $empty_line | Out-String
        Write-Warning "It seems that this script is run in a 'normal' PowerShell window."
        $empty_line | Out-String
        Write-Verbose "Please consider running this script in an elevated (administrator-level) PowerShell window." -Verbose
        $empty_line | Out-String
        $admin_text = "For performing system altering procedures, such as removing scheduled tasks, disabling services or writing the registry the elevated rights are mandatory. An elevated PowerShell session can, for example, be initiated by starting PowerShell with the 'run as an administrator' option."
        Write-Output $admin_text
        $empty_line | Out-String
        "Exiting without making any changes to the system." | Out-String
        Return ""
    } Else {
        $continue = $true
    } # Else


    # Check if the computer is connected to the Internet
    $empty_line | Out-String
    If (([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet) -eq $false) {
        "The Internet connection doesn't seem to be working. Exiting without syncing the time." | Out-String
        Return ""
    } Else {
        $continue = $true
        Write-Output = "Internet working: $continue"
    } # Else


    # Set the Windows Time sync parameters
    W32tm /config /manualpeerlist:"time.windows.com,0x1" /syncfromflags:MANUAL /reliable:YES /update
    W32tm /config /update
    Stop-Service  -Name "W32Time"
    Start-Service -Name "W32Time"


    # Sync Windows Time from an External Time Source
    W32tm /resync
    $empty_line | Out-String
}

# Getting Current Username for Downloading and Changing Directory
Write-Host "Getting current Windows User..."
[string]$username = [System.Environment]::UserName
Write-Host "Current Windows User: $username"


# Checking if WUT already exist in Download Folder
Write-Host "Checking if WUT exists in Download Folder..."
[bool]$WUTExists = Test-Path -Path "C:\Users\$username\Downloads\Update.exe" -PathType Leaf
if ($WUTExists -eq $true) {
    Write-Host "It exists! Running Update..."
    Start-Update
    Write-Output $empty_line
    Write-Output $empty_line
    Write-Host "$EndBanner"
    Exit
}

# Downloading and executing WUT if it didn't exist in Download Folder already
Get-Update
Start-Update

Write-Output $empty_line
Write-Output $empty_line
Write-Host "$EndBanner"
