resource "azurerm_network_interface" "windows_nic" {
  for_each = local.windows_vm_instances

  name                = "${module.naming.network_interface.name}-${each.key}"
  location            = var.location
  resource_group_name = module.resource_group.name

  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = module.vnet_test.subnets.vm_subnet_1.resource_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = module.pip_windows[each.key].resource_id
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each = local.windows_vm_instances

  name                       = "${module.naming.virtual_machine.name}-${each.value.vm_name}"
  resource_group_name        = module.resource_group.name
  location                   = var.location
  size                       = each.value.sku_size
  admin_username             = "azureuser"
  admin_password             = data.azurerm_key_vault_secret.azure_admin_password.value
  encryption_at_host_enabled = false

  network_interface_ids = [
    azurerm_network_interface.windows_nic[each.key].id,
  ]

  os_disk {
    name                 = "${module.naming.managed_disk.name}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }

  priority        = each.value.priority
  max_bid_price   = var.spot_max_price
  eviction_policy = var.eviction_policy
  patch_mode      = var.patch_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.uai_tfvm.id]
  }

  tags = each.value.tags
}

resource "azurerm_virtual_machine_extension" "ansible_preconfig" {
  for_each = local.windows_vm_instances

  name                       = "AnsiblePreConfiguration"
  virtual_machine_id         = azurerm_windows_virtual_machine.windows_vm[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "fileUris": [
      "https://raw.githubusercontent.com/${var.github_username}/terraform-az-infra/refs/heads/main/scripts/vm-config.ps1"
    ],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File vm-config.ps1"
  }
  SETTINGS
}

/* 
resource "azurerm_virtual_machine_extension" "keyvault" {
  for_each = local.windows_vm_instances

  name                       = "KeyVaultForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.windows_vm[each.key].id
  publisher                  = "Microsoft.Azure.KeyVault"
  type                       = "KeyVaultForWindows"
  type_handler_version       = "4.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    secretsManagementSettings = {
      pollingIntervalInS       = "60"
      certificateStoreName     = "My"  # Standard Windows certificate store
      certificateStoreLocation = "LocalMachine"
      observedCertificates = [
        # Dynamically construct the Key Vault secret URI for the certificate
        "https://${var.key_vault_name}.vault.azure.net/secrets/${each.key}-cert"
      ]
    }
    # Authentication using the VM's User Assigned Managed Identity
    authenticationSettings = {
      msiEndpoint = "http://169.254.169.254/metadata/identity"
      # Use the client ID of the assigned identity
      msiClientId = data.azurerm_user_assigned_identity.uai_tfvm.client_id
    }
  })
}
*/

resource "terraform_data" "trigger_ansible" {
  # This tells Terraform to always trigger this block on every successful run
  triggers_replace = [
    timestamp(),
    filemd5("${path.module}/scripts/trigger-ansible.ps1")
  ]

  # This ensures Terraform waits until ALL VMs in the module are fully created
  depends_on = [
    azurerm_windows_virtual_machine.windows_vm,
    azurerm_virtual_machine_extension.ansible_preconfig
    # You can also add your linux VM module here if you have one:
    # azurerm_linux_virtual_machine.linux_vm 
  ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "& '${path.module}/scripts/trigger-ansible.ps1' -GithubUsername '${var.github_username}' -AnsibleRepoName '${var.ansible_repo_name}'"
  }
}
