module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [var.workload_suffix, var.env_suffix]
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = module.naming.resource_group.name
  location = var.location
  tags     = var.tags
}
