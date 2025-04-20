# Check and switch network profile from Public to Private
Get-NetConnectionProfile |
  Where-Object NetworkCategory -Eq 'Public' |
  ForEach-Object {
    Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private
    Write-Host "Changed network profile on interface '$($_.InterfaceAlias)' to Private."
  }

# Enable PS Remoting with simple error handling
try {
    Enable-PSRemoting -Force -ErrorAction Stop
    Write-Host "PS Remoting enabled successfully."
}
catch {
    Write-Host "Failed to enable PS Remoting:" $_.Exception.Message
}
