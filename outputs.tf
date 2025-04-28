output "resource_group" {
  description = "Output resource group name"
  value       = module.resource_group.name
}

output "public_ip_addresses" {
  description = "Output public IP addresses for all VMs"
  value = merge(
    { for k, v in module.pip_windows : k => v.public_ip_address },
    { for k, v in module.pip_linux : k => v.public_ip_address }
  )
}

output "virtual_machine_names" {
  description = "Output VM names for all instances"
  value = merge(
    { for k, v in module.windows_vm : k => v.name },
    { for k, v in module.linux_vm : k => v.name }
  )
}

output "calculated_vm_instances" {
  description = "Calculated VM instances for both Windows and Linux VMs"
  value = {
    windows = local.windows_vm_instances
    linux   = local.linux_vm_instances
  }
}

output "windows_vm_fqdns" {
  description = "FQDN URLs for Windows VMs (https://<domain_name_label>.cloudapp.azure.com)"
  value = merge(
    { for k, v in module.pip_windows : k => "${module.naming.virtual_machine.name}-${k}.${var.location}.cloudapp.azure.com" },
    { for k, v in module.pip_linux : k => "${module.naming.virtual_machine.name}-linux-${k}.${var.location}.cloudapp.azure.com" }
  )
}