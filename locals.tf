# NSG Rules
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
    "allowicmp" = {
      name                       = "AllowICMP"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "*"
      direction                  = "Inbound"
      priority                   = 1001
      protocol                   = "Icmp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    "allowwinrm" = {
      name                       = "AllowWinRM"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "5985-5986"
      direction                  = "Inbound"
      priority                   = 1002
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}