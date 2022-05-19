$Banner = @"
██╗    ██╗ █████╗  ██████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
██║    ██║██╔══██╗██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
██║ █╗ ██║███████║██║         ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║
██║███╗██║██╔══██║██║         ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
╚███╔███╔╝██║  ██║╚██████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
 ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                                                                                                                           
███████╗ ██████╗██████╗ ██╗██████╗ ████████╗    ██╗   ██╗ ██╗    ██████╗                                                   
██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝    ██║   ██║███║   ██╔═████╗                                                  
███████╗██║     ██████╔╝██║██████╔╝   ██║       ██║   ██║╚██║   ██║██╔██║                                                  
╚════██║██║     ██╔══██╗██║██╔═══╝    ██║       ╚██╗ ██╔╝ ██║   ████╔╝██║                                                  
███████║╚██████╗██║  ██║██║██║        ██║        ╚████╔╝  ██║██╗╚██████╔╝                                                  
╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝         ╚═══╝   ╚═╝╚═╝ ╚═════╝  
"@

write-Host $Banner

$ConfigureIP = Read-Host "Configure IP-Adress? (J/N)"
if ($ConfigureIP -eq "J") {
Write-Host "Look for correct Interface Index:"
#adapter info
Get-NetAdapter

Write-Host "Few Configuration Steps required:"
$InterfaceIndex = Read-Host "Interface Index"
$IPAdress = Read-Host "IP Address"
$PrefixLength = Read-Host "PrefixLength"
$DefaultGateway = Read-Host "DefaultGateway"
Write-Host "Assigning IP-Settings..."
#static Ip Address
New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress $IPAdress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway

$DnsServer = Read-Host "DNS Server Address"
#set DNS
Write-Host "Assigning DNS-Settings..."
Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex  -ServerAddresses ($DnsServer)
}

#check hostname
write-Host "Check your Hostname"
hostname

#Entering a Remote PS Session
$hostname = Read-Host "Input Hostname"
$Credentials = Read-Host "Input Admin Credentials (mydomain\myuser)"
Write-Host "Entering Remote PS Session..."
Enter-PSSession -ComputerName $hostname -Credential $Credentials

#Create a new temp directory
$createDir = Read-Host "Create new Temp Directory? C:/Downloads (J/N)"
if ($createDir -eq "J") {
    Write-Host "Creating Temp-Directory..."
    New-Item -Path C:\Downloads -ItemType directory
}

#Download Windows Admin Center
$DownloadWAC = Read-Host "Download Windows Admin Center? (J/N)"
if ($DownloadWAC -eq "J") {
    Write-Host "Downloading latest WAC-Version..."
    Invoke-WebRequest "http://aka.ms/WACDownload" -outfile "C:\Downloads\WindowsAdminCenterCurrent.msi"
}

#Installation and Generating of a self signed SSL-Certificate
$DownloadPath = "C:\Downloads\"
if ($DownloadWAC -eq "N") {
    $DownloadPath = Read-Host "Select Download Path of WAC.msi"
}
$Port = Read-Host "Select prefered Port"
Set-Location $DownloadPath ; msiexec /i WindowsAdminCenterCurrent.msi /qn /L*v log.txt SME_PORT=$Port SSL_CERTIFICATE_OPTION=generate
Write-Host "Installing..."
Write-Host "Genarating SSL-Certificate..."

#Set Firewall Rules
$FirewallSelection = Read-Host "Apply Firewall Rules? (J/N)"
if ($FirewallSelection -eq "J") {
    New-NetFirewallRule -DisplayName 'HTTP-Inbound' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('80', $Port)
    New-NetFirewallRule -DisplayName 'HTTP-Outbound' -Profile @('Domain', 'Private') -Direction Outbound -Action Allow -Protocol TCP -LocalPort @('80', $Port)
}

#Testing Correct Installation
Write-Host "Getting IP Address of the Device"
$ipv4 = (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.status -ne "Disconnected"}).IPv4Address.IPAddress
Write-Host "Installation complete, Test with Workstation on same LAN"
Write-Host "Put the IP: " $ipv4 "into your Browser. Port for Web-Access: " $Port

write-Host "Script Installation Complete"

If ($Answer -eq "No")
{
$Repeat = $False
}

$Answer = Read-Host("Run Script again? (J/N)")
if ($Answer -eq "J"){
    . $PSCommandPath
}
else{
    Write-Host("Script ended")
}
