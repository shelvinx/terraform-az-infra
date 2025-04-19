output "resource_group" {
  description = "Output resource group name"
  value       = module.resource_group.name
}

output "pip_testvm" {
  description = "Output public ip address"
  value       = module.pip-testvm.public_ip_address
}

output "virtual_machine_name" {
  description = "Output virtual machine name"
  value       = module.testvm.name
}