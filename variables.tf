variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Location for resources"
  type        = string
}

variable "tags" {
  description = "List of tags to be applied"
  type        = map(string)
}

variable "workload_suffix" {
  description = "Naming module suffix for workload"
  type        = string
}

variable "env_suffix" {
  description = "Naming module suffix for environment"
  type        = string
}

variable "vnet_test_address_space" {
  description = "Address space for the test VNET"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.vnet_test_address_space : can(cidrhost(cidr, 0))])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
}

variable "vm_subnet_1_address_prefix" {
  description = "Address prefix for the VM subnet"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.vm_subnet_1_address_prefix : can(cidrhost(cidr, 0))])
    error_message = "The address prefix must be a valid CIDR notation."
  }
}

variable "windows_vm_sku_size" {
  description = "SKU size for the VM"
  type        = string
}

variable "linux_vm_sku_size" {
  description = "SKU size for Linux VMs."
  type        = string
}

variable "priority" {
  description = "Priority for the VM"
  type        = string

  validation {
    condition     = contains(["Spot", "Regular"], var.priority)
    error_message = "The priority must be either 'Spot' or 'Regular'."
  }
}

variable "spot_max_price" {
  description = "Maximum bid price for Spot VMs"
  type        = number
}

variable "eviction_policy" {
  description = "Eviction policy for Spot VMs"
  type        = string

  validation {
    condition     = contains(["Deallocate", "Delete"], var.eviction_policy)
    error_message = "The eviction policy must be either 'Deallocate' or 'Delete'."
  }
}

variable "windows_vm_count" {
  description = "Number of Windows VM instances to create."
  type        = number
}

variable "linux_vm_count" {
  description = "Number of Linux VM instances to create."
  type        = number
}

variable "patch_mode" {
  description = "Patch mode for the VM"
  type        = string

  validation {
    condition     = contains(["AutomaticByPlatform", "AutomaticByOS"], var.patch_mode)
    error_message = "The patch mode must be either 'AutomaticByPlatform' or 'AutomaticByOS'."
  }
}

variable "github_username" {
  description = "GitHub username or organization containing the ansible playbook repo"
  type        = string
}

variable "ansible_repo_name" {
  description = "Name of the Ansible playbook repository on GitHub"
  type        = string
}

variable "key_vault_rg" {
  description = "Resource group name where the Key Vault resides"
  type        = string
}
