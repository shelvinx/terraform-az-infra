# Terraform Azure Test Environment

## Overview
Built with [Azure Verified Modules](https://registry.terraform.io/namespaces/Azure) as it aligns with the Well-Architected Framework.

## Notes
- **Remote State:** State is stored remotely using Terraform Cloud, compatible with GitHub Actions.
- **Configuration Management:** VM Extension runs `vm-config.ps1` to enable WinRM for Ansible configuration management.
- **CAF Naming:** Utilizes the `naming` module for Cloud Adoption Framework naming conventions.
- **Scaling:** Adjust `vm_count` in `terraform.tfvars` to control the number of Windows VMs.
- **Spot VM Considerations:** Spot pricing may limit zone allocation; setting `zone = null` improves deployment success, otherwise Azure runs into Allocation failures breaking the deployment.

The `zone_number` locals can be used to assign a random Availability Zone to the VMs.

---