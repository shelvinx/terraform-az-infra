# Terraform Azure Test Environment

## Overview
Built with [Azure Verified Modules](https://registry.terraform.io/namespaces/Azure) as it aligns with the Well-Architected Framework.


## Important Environment & Module Notes
- **VM Computer Name Length:**
  - Azure restricts Windows VM computer names to 15 characters max. Ensure your naming logic (locals, modules) produces names ≤ 15 chars

- **Scaling VMs:**
  - Increase/decrease `windows_vm_count` or `linux_vm_count` in `terraform.tfvars` to scale up/down. Reducing count will destroy the highest-indexed VMs first.
  Use `Apply` to scale
  Use `Destroy` to remove VMs

- **Linux Password Authentication:** TODO: SSH Key Auth
  - The AVM Linux VM module disables password authentication by default. To enable, set `password_authentication_disabled = false` in the `admin_credentials` block.
  - Default username: `azureuser`

- **Output Merging:**
  - Outputs for VM names and IPs use `merge()` to combine Windows and Linux resources into a single map.

## ENVIRONMENT VARIABLES
- `ADMIN_PASSWORD` (required for provisioning VMs)
- `AZURE_SUBSCRIPTION_ID` (used by Terraform provider)

---

For more details, see the module documentation or reach out to the project maintainer.