module "vnet_test" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = module.naming.virtual_network.name
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_test_address_space

  subnets = {
    vm_subnet_1 = {
      name             = "${module.naming.subnet.name}"
      address_prefixes = "${var.vm_subnet_1_address_prefix}"
      network_security_group = {
        id = "${module.nsg_test.resource_id}"
      }
    }
  }

  tags = var.tags
}

module "nsg_test" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  location            = var.location
  resource_group_name = module.resource_group.name
  name                = module.naming.network_security_group.name

  security_rules = local.nsg_rules # Defined in locals.tf

  tags = var.tags
}

module "pip_windows" {
  for_each = toset(local.windows_vm_instances)
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.0"

  location            = var.location
  resource_group_name = module.resource_group.name
  name                = "${module.naming.public_ip.name}-${each.key}"

  tags = var.tags
}

module "pip_linux" {
  for_each = toset(local.linux_vm_instances)
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.0"

  location            = var.location
  resource_group_name = module.resource_group.name
  name                = "${module.naming.public_ip.name}-linux-${each.key}"

  tags = var.tags
}