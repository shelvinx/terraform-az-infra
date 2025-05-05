# Terraform Azure Test Environment

## Overview
Built with [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) as it aligns with the Well-Architected Framework and the `Naming` module which uses CAF naming conventions.

## Important Environment & Module Notes
- **VM Computer Name Length:**
  - Azure restricts Windows VM computer names to 15 characters max. Ensure naming logic (locals, modules) produces names ≤ 15 chars

- **For_Each Loop for VM Creation**
  - Increase/decrease `windows_vm_count` or `linux_vm_count` in `terraform.tfvars` to scale up/down. Reducing count will destroy the highest-indexed VMs first.
  - `Locals` will define specific variables. Tags are used in Ansible playbooks. 
  For example: `role: webserver` will be targetted by the Ansible playbook for installing Web Server.

  Use `Apply` to scale
  Use `Destroy` to remove VMs

  *Scale Sets should be used for identical VMs.*

- **VM Extensions**
  - Script Extension - configures firewall rules for Ansible.
  - KeyVault Extension - [Windows] Retrieves certificate from Key Vault and installs it.
    KV Permissions are provided with a `User Assigned ID`.

- **Output Merging:**
  - Outputs for VM names and IPs use `merge()` to combine Windows and Linux resources into a single map.

## ENVIRONMENT VARIABLES
- `ADMIN_PASSWORD` (HCP Vault - Set as TF_VAR ENV Variable, this removes the undeclared variable warning.)

---