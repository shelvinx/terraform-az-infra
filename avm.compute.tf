# AVM Virtual Machine
module "testvm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.0"

  location                   = var.location
  resource_group_name        = module.resource_group.name
  name                       = module.naming.virtual_machine.name
  os_type                    = var.os_type
  sku_size                   = var.vm_sku_size
  zone                       = var.vm_zone
  encryption_at_host_enabled = false

  account_credentials = {
    admin_credentials = {
      username                           = "azureuser"
      password                           = var.admin_password
      generate_admin_password_or_ssh_key = false
    }
  }


  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-g2"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "${module.naming.network_interface.name_unique}"
      ip_configurations = {
        ip_configurations_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig"
          private_ip_subnet_resource_id = "${module.vnet_test.subnets.vm_subnet_1.resource_id}"
          public_ip_address_resource_id = "${module.pip-testvm.resource_id}"
        }
      }
    }
  }

  priority        = var.priority
  max_bid_price   = var.spot_max_price
  eviction_policy = var.eviction_policy

  extensions = {
    script = {
      name                       = "ConfigurationScript"
      publisher                  = "Microsoft.Compute"
      type                       = "CustomScriptExtension"
      type_handler_version       = "1.10"
      auto_upgrade_minor_version = true
      settings = <<SETTINGS
      {
        "fileUris": [
          "https://raw.githubusercontent.com/shelvinx/terraform-az-infra/refs/heads/main/scripts/vm-config.ps1"
        ],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File vm-config.ps1"
      }
      SETTINGS
    }
  }
}