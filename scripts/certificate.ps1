# Script to check for/create and install SSL certificate using wacs.exe and Key Vault

param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName, # Needed to get VM FQDN

    [Parameter(Mandatory=$true)]
    [string]$VmName, # Needed to get VM FQDN

    [string]$WacsExePath = "C:\Program Files\win-acme\wacs.exe", # Default path, adjust if needed

    [string]$ContactEmail = "your-admin-email@example.com" # Replace with actual contact
)

# --- Prerequisites ---
# Ensure Azure PowerShell module is available (Install-Module Az -Scope CurrentUser -Force -AllowClobber if needed)
Import-Module Az.Accounts -ErrorAction Stop
Import-Module Az.Compute -ErrorAction Stop
Import-Module Az.KeyVault -ErrorAction Stop

# --- Configuration ---
Write-Host "Script started. Parameters: KeyVaultName=$KeyVaultName, ResourceGroupName=$ResourceGroupName, VmName=$VmName"

# --- Connect to Azure using System Assigned Managed Identity ---
try {
    Connect-AzAccount -Identity
    Write-Host "Successfully connected to Azure using Managed Identity."
} catch {
    Write-Error "Failed to connect to Azure using Managed Identity: $_"
    exit 1
}

# --- Get VM FQDN ---
try {
    # Get the primary NIC of the VM
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -ErrorAction Stop
    $nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $vm.NetworkProfile.NetworkInterfaces[0].Id.Split('/')[-1] -ErrorAction Stop
    # Get the public IP associated with the NIC
    $pip = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $nic.IpConfigurations[0].PublicIpAddress.Id.Split('/')[-1] -ErrorAction Stop
    $fqdn = $pip.DnsSettings.Fqdn
    if (-not $fqdn) {
        Write-Error "FQDN not found for VM $VmName in Resource Group $ResourceGroupName."
        exit 1
    }
    Write-Host "Determined FQDN: $fqdn"
} catch {
    Write-Error "Failed to retrieve FQDN for VM $VmName: $_"
    exit 1
}


# --- Define Certificate Name in Key Vault (replace dots with dashes) ---
$certificateNameInKV = $fqdn.Replace('.', '-')
Write-Host "Certificate name in Key Vault will be: $certificateNameInKV"

# --- Check if Certificate Exists in Key Vault ---
$certificate = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $certificateNameInKV -ErrorAction SilentlyContinue

if ($certificate) {
    # --- Certificate Found - Download and Install ---
    Write-Host "Certificate '$certificateNameInKV' found in Key Vault '$KeyVaultName'."
    try {
        Write-Host "Downloading certificate from Key Vault..."
        # Get the secret value (which is the PFX)
        $secretValue = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $certificateNameInKV -AsPlainText
        $pfxFilePath = Join-Path $env:TEMP "$certificateNameInKV.pfx"

        # Convert Base64 string back to bytes and save as PFX
        $pfxBytes = [System.Convert]::FromBase64String($secretValue)
        [System.IO.File]::WriteAllBytes($pfxFilePath, $pfxBytes)
        Write-Host "PFX file saved to $pfxFilePath"

        # Import the certificate to the Local Machine store (Web Hosting store is common for IIS)
        # The PFX from Key Vault usually doesn't have a password when retrieved via Managed Identity/Secret GET
        Write-Host "Importing certificate to LocalMachine\My store..."
        Import-PfxCertificate -FilePath $pfxFilePath -CertStoreLocation "Cert:\LocalMachine\My" -ErrorAction Stop
        Write-Host "Certificate successfully imported."

        # Clean up temporary PFX file
        Remove-Item -Path $pfxFilePath -Force
    } catch {
        Write-Error "Failed to download or install certificate from Key Vault: $_"
        # Decide if you want to exit or try creating a new one
        exit 1
    }

} else {
    # --- Certificate Not Found - Create using wacs.exe ---
    Write-Host "Certificate '$certificateNameInKV' not found in Key Vault '$KeyVaultName'. Attempting to create..."

    # Check if wacs.exe exists
    if (-not (Test-Path $WacsExePath)) {
        Write-Error "wacs.exe not found at '$WacsExePath'. Please ensure win-acme is installed."
        # Consider adding logic here to download/install wacs.exe if desired
        exit 1
    }

    # Construct wacs.exe command
    $wacsArgs = @(
        "--accepttos"
        "--host", $fqdn
        "--source", "manual" # Manual source because we provide the host directly
        "--store", "keyvault"
        "--azureusemsi"
        "--vaultname", $KeyVaultName
        "--certificatename", $certificateNameInKV
        "--emailaddress", $ContactEmail
        "--notaskscheduler" # Don't create a scheduled task for renewal on this VM
        #"--test" # Remove for production
        "--verbose"
    )

    Write-Host "Running wacs.exe command: $WacsExePath $wacsArgs"
    try {
        # Execute wacs.exe
        # Using Start-Process to handle potential elevation requirements or separate window behavior if needed
        # Using -Wait ensures the script waits for wacs.exe to finish
        # Using -PassThru gets the process object to check ExitCode
        $process = Start-Process -FilePath $WacsExePath -ArgumentList $wacsArgs -Wait -PassThru -ErrorAction Stop

        if ($process.ExitCode -ne 0) {
             Write-Error "wacs.exe failed with exit code $($process.ExitCode)."
             # Add logic here to read wacs logs if necessary
             exit 1
        }

        Write-Host "wacs.exe completed successfully. Certificate should be stored in Key Vault."

        # --- Download and Install the Newly Created Certificate ---
        Write-Host "Downloading the newly created certificate from Key Vault..."
        # Short delay to allow Key Vault replication if needed
        Start-Sleep -Seconds 10 
        $newSecretValue = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $certificateNameInKV -AsPlainText -ErrorAction Stop
        $newPfxFilePath = Join-Path $env:TEMP "$certificateNameInKV.pfx"
        $newPfxBytes = [System.Convert]::FromBase64String($newSecretValue)
        [System.IO.File]::WriteAllBytes($newPfxFilePath, $newPfxBytes)
        Write-Host "PFX file saved to $newPfxFilePath"

        Write-Host "Importing newly created certificate to LocalMachine\My store..."
        Import-PfxCertificate -FilePath $newPfxFilePath -CertStoreLocation "Cert:\LocalMachine\My" -ErrorAction Stop
        Write-Host "Certificate successfully imported."

        # Clean up
        Remove-Item -Path $newPfxFilePath -Force

    } catch {
        Write-Error "Failed to execute wacs.exe or install the newly created certificate: $_"
        exit 1
    }
}

Write-Host "Certificate script finished successfully."
exit 0 # Success