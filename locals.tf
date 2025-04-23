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
    "allowssh" = {
      name                       = "AllowSSH"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "22"
      direction                  = "Inbound"
      priority                   = 1003
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}

# Random Integer for Zone
locals {
  zone_number = random_integer.random_zone.result
}

# Number of VM instances to be created
locals {
  windows_vm_instances = [for i in range(var.windows_vm_count) : "win${i + 1}"]
  linux_vm_instances   = [for i in range(var.linux_vm_count) : "lin${i + 1}"]
}