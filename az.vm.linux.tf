resource "azurerm_network_interface" "linux_nic" {
  for_each = local.linux_vm_instances

  name                = "${module.naming.network_interface.name}-${each.key}"
  location            = var.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = module.vnet_test.subnets.vm_subnet_1.resource_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = module.pip_linux[each.key].resource_id
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  for_each = local.linux_vm_instances

  name                            = "${module.naming.virtual_machine.name}-${each.value.vm_name}"
  resource_group_name             = module.resource_group.name
  location                        = var.location
  size                            = each.value.sku_size
  admin_username                  = "azureuser"
  admin_password                  = data.azurerm_key_vault_secret.azure_admin_password.value
  disable_password_authentication = false
  encryption_at_host_enabled      = false

  network_interface_ids = [
    azurerm_network_interface.linux_nic[each.key].id,
  ]

  os_disk {
    name                 = "${module.naming.managed_disk.name}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  priority        = each.value.priority
  max_bid_price   = var.spot_max_price
  eviction_policy = var.eviction_policy

  tags = each.value.tags
}

resource "azurerm_virtual_machine_extension" "nginx" {
  for_each = local.linux_vm_instances

  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm[each.key].id

  name                 = "nginx"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
    "commandToExecute": "sudo apt-get update && sudo apt-get install nginx -y && echo \"VM Hostname: $(hostname)\" > /var/www/html/index.html && sudo systemctl restart nginx"
    }
    SETTINGS
}
