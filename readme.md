# Terraform Azure Test Environment

Written using Azure Verified Modules

State stored remotely using `TF Cloud` which is compatible with Github Actions.

Multiple instances can be created by modifying the `vm_count` variable

Availability Zone set to `Null` due to Azure allocation issues; possibly related with using Spot pricing.

VM Extension runs `vm-config.ps1` to enable WinRM for Ansible Configuration Management.