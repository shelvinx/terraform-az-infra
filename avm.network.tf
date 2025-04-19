module "vnet_test" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = module.naming.virtual_network.name
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_test_address_space

  subnets = {
    vm_subnet_1 = {
      name             = "${module.naming.subnet.name_unique}"
      address_prefixes = "${var.vm_subnet_1_address_prefix}"
      network_security_group = {
        id = "${module.nsg_test.resource_id}"
      }
    }
  }
}

module "nsg_test" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  location            = var.location
  resource_group_name = module.resource_group.name
  name                = module.naming.network_security_group.name_unique

  security_rules = local.nsg_rules
}

module "pip-testvm" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.2.0"

  location            = var.location
  resource_group_name = module.resource_group.name
  name                = module.naming.public_ip.name_unique
}