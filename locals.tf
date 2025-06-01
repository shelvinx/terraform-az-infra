# VM instances configuration
# Available Ansible Roles: domaincontroller, webserver

locals {
  # Define default values for Windows VMs
  windows_vm_defaults = {
    sku_size = var.windows_vm_sku_size
    tags     = var.tags
    priority = var.priority
  }

  # Define override values for Windows VMs
  windows_vm_configs = {
    ws1 = {
      vm_name  = "ws1"
      sku_size = "Standard_F2s_v2" # Override default SKU
      tags = merge(var.tags, {
        role = "none"
      })
    }
    # Add more VMs with custom configurations as needed
  }

  # Merge defaults with specific configurations, selecting based on count
  windows_vm_instances = { for name in slice(sort(keys(local.windows_vm_configs)), 0, var.windows_vm_count) :
    name => merge(local.windows_vm_defaults, local.windows_vm_configs[name])
  }

  # Define default values for Linux VMs
  linux_vm_defaults = {
    sku_size = var.linux_vm_sku_size
    tags     = var.tags
    priority = var.priority
  }

  # Define override values for Linux VMs
  linux_vm_configs = {
    lnx1 = {
      vm_name = "lnx1"
      #  sku_size = "Standard_D2s_v3"  # Override default SKU
      tags = merge(var.tags, {
        role = "webserver"
      })
    }
    # Add more VMs with custom configurations as needed
    lnx2 = {
      vm_name = "lnx2"
      #  sku_size = "Standard_D2s_v3"  # Override default SKU
      tags = merge(var.tags, {
        role = "webserver"
      })
    }
  }

  # Merge defaults with specific configurations, selecting based on count
  linux_vm_instances = { for name in slice(sort(keys(local.linux_vm_configs)), 0, var.linux_vm_count) :
    name => merge(local.linux_vm_defaults, local.linux_vm_configs[name])
  }
}

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
    "allowhttp" = {
      name                       = "AllowHTTP"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "80"
      direction                  = "Inbound"
      priority                   = 1004
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    "allowhttps" = {
      name                       = "AllowHTTPS"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "443"
      direction                  = "Inbound"
      priority                   = 1005
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
