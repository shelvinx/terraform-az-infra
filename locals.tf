# Local variables for NSG rules
locals {
  nsg_rules = {
    "allowrdp" = {
      name                       = "AllowRDP"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "3389"
      direction                  = "Inbound"
      priority                   = 1000
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}