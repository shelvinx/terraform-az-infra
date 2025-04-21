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

variable "admin_password" {
  type        = string
  description = "Administrator password"
  sensitive   = true

  validation {
    condition = (
      length(var.admin_password) >= 12 &&
      can(regex("[a-zA-Z0-9]", var.admin_password)) &&
      can(regex("[\\W_]", var.admin_password))
    )
    error_message = "Password must be at least 12 characters and contain both alphanumeric and special characters."
  }
}

variable "os_type" {
  description = "Operating system type for the VM"
  type        = string

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "The OS type must be either 'Linux' or 'Windows'."
  }
}

variable "vm_sku_size" {
  description = "SKU size for the VM"
  type        = string

  validation {
    condition     = length(var.vm_sku_size) > 0
    error_message = "The VM SKU size cannot be empty."
  }
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