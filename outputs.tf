output "resource_group" {
  description = "Output resource group name"
  value       = module.resource_group.name
}

output "public_ip_addresses" {
  description = "Output public IP addresses for all VMs"
  value       = { for k, v in module.pip : k => v.public_ip_address }
}

output "virtual_machine_names" {
  description = "Output VM names for all instances"
  value       = { for k, v in module.testvm : k => v.name }
}

output "calculated_vm_instances" {
  value = local.vm_instances
}