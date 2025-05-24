variable "naming" {
  description = "Naming module output for consistent naming"
  type = object({
    recovery_services_vault = object({
      name = string
    })
    site_recovery_replication_policy = object({
      name = string
    })
  })
}

variable "primary_region" {
  type        = string
  description = "Primary Azure region for the ASR vault"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create resources in"
}

variable "dr_region" {
  type        = string
  description = "Target disaster recovery region (e.g., 'ukwest')"
  default     = "ukwest"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'staging', 'prod')"
  default     = "prod"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources"
  default     = {}
}

# Replication policy variables
variable "recovery_point_retention_hours" {
  type        = number
  description = "Retention period for recovery points in hours"
  default     = 24
  
  validation {
    condition     = var.recovery_point_retention_hours >= 1 && var.recovery_point_retention_hours <= 24
    error_message = "Recovery point retention must be between 1 and 24 hours for Standard tier."
  }
}

variable "app_consistent_snapshot_frequency_minutes" {
  type        = number
  description = "Frequency of application-consistent snapshots in minutes. Must be one of: 30, 60, 120, 180, 240, 300, 360, 480, 540, 600, 720, 900, 960, 1200, 1440, 2880, 4320, 5040, 7200, 10080"
  default     = 240  # 4 hours
  
  validation {
    condition     = contains([30, 60, 120, 180, 240, 300, 360, 480, 540, 600, 720, 900, 960, 1200, 1440, 2880, 4320, 5040, 7200, 10080], var.app_consistent_snapshot_frequency_minutes)
    error_message = "App consistent snapshot frequency must be one of: 30, 60, 120, 180, 240, 300, 360, 480, 540, 600, 720, 900, 960, 1200, 1440, 2880, 4320, 5040, 7200, or 10080 minutes."
  }
}
