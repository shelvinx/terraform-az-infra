# Check and switch network profile from Public to Private
try {
Get-NetConnectionProfile |
  Where-Object NetworkCategory -Eq 'Public' |
  ForEach-Object {
    Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private
    Write-Host "Changed network profile on interface '$($_.InterfaceAlias)' to Private."
  }
}
catch {
    Write-Host "Failed to change network profile:" $_.Exception.Message
}

# Enable PS Remoting with simple error handling
try {
    Enable-PSRemoting -Force -ErrorAction Stop
    Write-Host "PS Remoting enabled successfully."
}
catch {
    Write-Host "Failed to enable PS Remoting:" $_.Exception.Message
}

# Create self signed certificate
try {
$certParams = @{
    CertStoreLocation = 'Cert:\LocalMachine\My'
    DnsName           = $env:COMPUTERNAME
    NotAfter          = (Get-Date).AddYears(1)
    Provider          = 'Microsoft Software Key Storage Provider'
    Subject           = "CN=$env:COMPUTERNAME"
}
$cert = New-SelfSignedCertificate @certParams
}
catch {
    Write-Host "Failed to create self-signed certificate:" $_.Exception.Message
}

# Create HTTPS listener
try {
$httpsParams = @{
    ResourceURI = 'winrm/config/listener'
    SelectorSet = @{
        Transport = "HTTPS"
        Address   = "*"
    }
    ValueSet = @{
        CertificateThumbprint = $cert.Thumbprint
        Enabled               = $true
    }
}
New-WSManInstance @httpsParams
}
catch {
    Write-Host "Failed to create HTTPS listener:" $_.Exception.Message
}

try {
# Opens port 5986 for all profiles
$firewallParams = @{
    Action      = 'Allow'
    Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
    Direction   = 'Inbound'
    DisplayName = 'Windows Remote Management (HTTPS-In)'
    LocalPort   = 5986
    Profile     = 'Any'
    Protocol    = 'TCP'
}
New-NetFirewallRule @firewallParams
}
catch {
    Write-Host "Failed to create firewall rule:" $_.Exception.Message
}