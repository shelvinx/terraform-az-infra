data "azurerm_user_assigned_identity" "uai_tfvm" {
  name                = "uai-tfvm"
  resource_group_name = "rg-platform"
}

# Fetch the deployer's public IP using Cloudflare's icanhazip service
data "http" "deployer_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Read existing Key Vault
data "azurerm_key_vault" "rain" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}

# Get the Windows Admin Password from KV
data "azurerm_key_vault_secret" "azure_admin_password" {
  name         = "azure-admin-password"
  key_vault_id = data.azurerm_key_vault.rain.id
}
