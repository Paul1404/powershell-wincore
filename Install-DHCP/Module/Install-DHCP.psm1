function Install-DHCP {
    param (
        [Parameter(Position=0)]
        [string]$StartRange,

        [Parameter(Position=1)]
        [string]$EndRange,

        [Parameter(Position=2)]
        [string]$SubMask,

        [Parameter(Position=3)]
        [string]$Name,

        [Parameter(Position=4)]
        [string]$LeaseDur,

        [Parameter(Position=5)]
        [string]$ScopeID,

        [Parameter(Position=6)]
        [string]$DNS,

        [Parameter(Position=7)]
        [string]$Router,

        [Parameter(Position=8)]
        [string]$DnsDomain,

        [Parameter(Position=9)]
        [string]$DNSName
    )
process {

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
if ($PSBoundParameters.ContainsKey('StartRange') -eq $false) {
    $StartRange = Read-Host "Input IPV4 StartRange"
}
if ($PSBoundParameters.ContainsKey('EndRange') -eq $false) {
$EndRange = Read-Host "Input IPV4 Endrange"
}
if ($PSBoundParameters.ContainsKey('SubMask') -eq $false) {
$SubMask = Read-Host "Input IPV4 Subnet Mask"
}
if ($PSBoundParameters.ContainsKey('Name') -eq $false) {
$Name = Read-Host "Input Scope Name"
}
if ($PSBoundParameters.ContainsKey('LeaseDur') -eq $false) {
$LeaseDur = Read-Host "Input Lease Duration in the following format (D.HH.MM.SS)"
}
Add-DhcpServerv4Scope -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubMask -Name $Name -LeaseDuration $LeaseDur
if ($PSBoundParameters.ContainsKey('ScopeID') -eq $false) {
$ScopeID = Read-Host "Input Scope ID (XXX.XXX.XXX.0)"
}
if ($PSBoundParameters.ContainsKey('DNS') -eq $false) {
$DNS = Read-Host "Input DNS"
}
if ($PSBoundParameters.ContainsKey('Router') -eq $false) {
$Router = Read-Host "Input Gateway IP"
}
if ($PSBoundParameters.ContainsKey('DnsDomain') -eq $false) {
$DnsDomain = Read-Host "Input DNS Domain"
}
Set-DhcpServerv4OptionValue -ScopeId $ScopeID -DnsServer $DNS -Router $Router -DnsDomain $DnsDomain

#Get a list of scopes
Write-Host ("Check if Scope is Correct")
Get-DhcpServerv4Scope

#Authorize the DHCP server
$DNSName = Read-Host "Input the Hostname of the DNS-Server"
Add-DhcpServerInDC -DnsName $DNSName

#Delete Warning Message in ServerManager
Set-ItemProperty –Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
    }
}