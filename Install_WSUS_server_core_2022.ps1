$Banner = @"

██╗    ██╗███████╗██╗   ██╗███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     
██║    ██║██╔════╝██║   ██║██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     
██║ █╗ ██║███████╗██║   ██║███████╗    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     
██║███╗██║╚════██║██║   ██║╚════██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     
╚███╔███╔╝███████║╚██████╔╝███████║    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
 ╚══╝╚══╝ ╚══════╝ ╚═════╝ ╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
                                                                                             
███████╗ ██████╗██████╗ ██╗██████╗ ████████╗    ██╗   ██╗     ██╗    ██████╗                 
██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝    ██║   ██║    ███║   ██╔═████╗                
███████╗██║     ██████╔╝██║██████╔╝   ██║       ██║   ██║    ╚██║   ██║██╔██║                
╚════██║██║     ██╔══██╗██║██╔═══╝    ██║       ╚██╗ ██╔╝     ██║   ████╔╝██║                
███████║╚██████╗██║  ██║██║██║        ██║        ╚████╔╝      ██║██╗╚██████╔╝                
╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝         ╚═══╝       ╚═╝╚═╝ ╚═════╝                 
"@

#Add the WSUS role and install the required roles/features
Write-Host "Installing WSUS Server Role including ManagementTools"
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
#Configure WSUS post install

#Create a directory for WSUS
$createDirectory = Read-Host "Create New WSUS Directory under C:\WSUS\? (J/N)"
if ($createDirectory -eq "J") {
    New-Item 'C:\WSUS' -ItemType Directory
    $WsusDirectory = "C:\WSUS"
}

Write-Host "Intializing Post-Install Process and settig Content-Directory Path..."
$WsusDirectory = Read-Host "Choose your prefered WSUS-Content-Directory"
'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall CONTENT_DIR=$WsusDirectory

#Change different WSUS config items
Write-Host "Few Configuration Steps required..."
$wsus = Get-WSUSServer
$wsusConfig = $wsus.GetConfiguration()
Write-Host "Setting Synchronization Source to Microsoft Update..."
Set-WsusServerSynchronization –SyncFromMU

#Proxy Configuration
$useProxy = read-Host "Use Proxy Server in WSUS? (J/N)"
if ($useProxy -eq "J") {
$wsusConfig.UseProxy=$true
[string]$proxyAddress = Read-Host "Input Proxy IPV4 Address (XXX.XXX.XXX.XXX)"
$wsusConfig.ProxyName= $proxyAddress
$wsusConfig.Save()
}

#All Language Updates
$allanguageupdates = read-Host "Enable All Language Updates? (J/N)"
if ($allanguageupdates -ne "J") {
$wsusConfig.AllUpdateLanguagesEnabled = $false
} else {$wsusConfig.AllUpdateLanguagesEnabled = $true}

#Set prefered Language Updates
[string]$UpdateLanguage = read-Host "Input Enabled-Update-Languages in the following form (de/en) etc."
$wsusConfig.SetEnabledUpdateLanguages($UpdateLanguage)
$wsusConfig.Save()

$wsusConfig.TargetingMode='Client'
$wsusConfig.Save()

#Get WSUS Subscription and perform initial synchronization to get latest categories
Write-Host "Getting WSUS Subscription and intitial synchronization"
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
# $subscription.GetSynchronizationStatus() should not be Running to be done
# $subscription.GetSynchronizationProgress() shows you the actual progress in case status is running
write-Host "Current Progress"
$subscription.GetSynchronizationProgress()

$wsusConfig.OobeInitialized = $true
$wsusConfig.Save()

#Get only 2022 updates
write-Host "Setting Products to the 2022 Versions"
Get-WsusProduct | Where-Object {$_.Product.Title -ne "Windows Server 2022"} | Set-WsusProduct -Disable
Get-WsusProduct | Where-Object {$_.Product.Title -eq "Windows Server 2022"} | Set-WsusProduct
Get-WsusProduct | Where-Object {$_.Product.Title -ne "Windows 10"} | Set-WsusProduct -Disable
Get-WsusProduct | Where-Object {$_.Product.Title -eq "Windows 10"} | Set-WsusProduct
#Get only specific classifications
write-Host "Getting specific classifications"
Get-WsusClassification | Where-Object { $_.Classification.Title -notin 'Update Rollups','Security Updates','Critical Updates','Updates','Service Packs'  } | Set-WsusClassification -Disable
Get-WsusClassification | Where-Object { $_.Classification.Title -in 'Update Rollups','Security Updates','Critical Updates','Updates','Service Packs'  } | Set-WsusClassification

#Start a sync
write-Host "Starting the secon Synchronization"
$subscription.StartSynchronization()
$subscription.GetSynchronizationProgress()
$subscription.GetSynchronizationStatus()

Write-host "Initial Installation Completed"
write-host "Now create a GPO and set client side targeting and intranet wsus server"

write-host "Test the updates on one of the servers that the GPO applies to, do not forget to issue a gpudate /force before"