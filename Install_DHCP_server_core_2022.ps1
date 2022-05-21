$Banner = @"
██████╗ ██╗  ██╗ ██████╗██████╗      ██████╗ ███╗   ██╗ 
██╔══██╗██║  ██║██╔════╝██╔══██╗    ██╔═══██╗████╗  ██║ 
██║  ██║███████║██║     ██████╔╝    ██║   ██║██╔██╗ ██║ 
██║  ██║██╔══██║██║     ██╔═══╝     ██║   ██║██║╚██╗██║ 
██████╔╝██║  ██║╚██████╗██║         ╚██████╔╝██║ ╚████║ 
╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝          ╚═════╝ ╚═╝  ╚═══╝ 
                                                        
██╗    ██╗██╗███╗   ██╗ ██████╗ ██████╗ ██████╗ ███████╗
██║    ██║██║████╗  ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║ █╗ ██║██║██╔██╗ ██║██║     ██║   ██║██████╔╝█████╗  
██║███╗██║██║██║╚██╗██║██║     ██║   ██║██╔══██╗██╔══╝  
╚███╔███╔╝██║██║ ╚████║╚██████╗╚██████╔╝██║  ██║███████╗
 ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
"@

Write-Host $Banner

#Install the DHCP Role
Install-WindowsFeature DHCP

#Create scope and set options
$StartRange = Read-Host "Input IPV4 StartRange:"
$EndRange = Read-Host "Input IPV4 Endrange"
$SubMask = Read-Host "Input IPV4 Subnet Mask"
$Name = Read-Host "Input Scope Name"
$LeaseDur = Read-Host "Input Lease Duration in the following format (D.HH.MM.SS)"
Add-DhcpServerv4Scope -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubMask -Name $Name -LeaseDuration $LeaseDur
$ScopeID = Read-Host "Input Scope ID (XXX.XXX.XXX.0)"
$DNS = Read-Host "Input DNS"
$Router = Read-Host "Input Gateway IP"
[string]$DnsDomain = Read-Host "Input DNS Domain"
Set-DhcpServerv4OptionValue -ScopeId $ScopeID -DnsServer $DNS -Router $Router -DnsDomain $DnsDomain

#Get a list of scopes
Write-Host ("Check if Scope is Correct")
Get-DhcpServerv4Scope

#Authorize the DHCP server
$DNSName = Read-Host "Input the Hostname of the DNS-Server"
Add-DhcpServerInDC -DnsName $DNSName

#Delete Warning Message in ServerManager
Set-ItemProperty –Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2