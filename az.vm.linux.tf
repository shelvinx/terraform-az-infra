# AVM Linux Virtual Machine
module "linux_vm" {
  for_each = local.linux_vm_instances
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.0"

  location                   = var.location
  resource_group_name        = module.resource_group.name
  name                       = "${module.naming.virtual_machine.name}-${each.value.vm_name}"
  os_type                    = "Linux"
  sku_size                   = each.value.sku_size
  zone                       = null
  encryption_at_host_enabled = false

  account_credentials = {
    admin_credentials = {
      username                           = "azureuser"
      password                           = var.admin_password # To be updated: SSH KEY
      generate_admin_password_or_ssh_key = false
    }
    password_authentication_disabled   = false
  }

  os_disk = {
    name                 = "${module.naming.managed_disk.name}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "${module.naming.network_interface.name}-${each.key}"
      ip_configurations = {
        ip_configurations_1 = {
          name                          = "ipconfig-${each.key}"
          private_ip_subnet_resource_id = module.vnet_test.subnets.vm_subnet_1.resource_id
          public_ip_address_resource_id = module.pip_linux[each.key].resource_id
        }
      }
    }
  }

  priority        = each.value.priority
  max_bid_price   = var.spot_max_price
  eviction_policy = var.eviction_policy

  tags = each.value.tags
}