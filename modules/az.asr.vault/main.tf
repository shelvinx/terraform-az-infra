# ASR Vault Module
# Creates a Recovery Services Vault for Azure Site Recovery (ASR) with cross-region DR

resource "azurerm_recovery_services_vault" "asr_vault" {
  name                = var.naming.recovery_services_vault.name
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  
  # Enable cross-region restore for DR to target region
  cross_region_restore_enabled = true
  
  # Enable soft delete for protection against accidental deletion
  soft_delete_enabled = true

  tags = var.tags
}

# Replication Policy for ASR
resource "azurerm_site_recovery_replication_policy" "replication_policy" {
  name                                                 = var.naming.site_recovery_replication_policy.name
  resource_group_name                                  = var.resource_group_name
  recovery_vault_name                                  = azurerm_recovery_services_vault.asr_vault.name
  
  # Recovery point retention in minutes (must be between 60 and 10080 - 1 to 7 days)
  recovery_point_retention_in_minutes = min(max(60, var.recovery_point_retention_hours * 60), 10080)
  
  # Frequency of application-consistent snapshots in minutes (must be 30, 60, 120, 180, 240, 300, 360, 480, 540, 600, 720, 900, 960, 1200, 1440, 2880, 4320, 5040, 7200, 10080)
  application_consistent_snapshot_frequency_in_minutes = contains([30, 60, 120, 180, 240, 300, 360, 480, 540, 600, 720, 900, 960, 1200, 1440, 2880, 4320, 5040, 7200, 10080], var.app_consistent_snapshot_frequency_minutes) ? var.app_consistent_snapshot_frequency_minutes : 240
}

# Outputs
output "vault_id" {
  description = "The ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.asr_vault.id
}

output "vault_name" {
  description = "The name of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.asr_vault.name
}

output "replication_policy_id" {
  description = "The ID of the replication policy"
  value       = azurerm_site_recovery_replication_policy.replication_policy.id
}
