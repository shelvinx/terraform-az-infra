# Terraform Provider for Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
    # Required for the naming module
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.1"
    }
  }

  # Configure Terraform Cloud for Remote State Management
  cloud {
    organization = "az-env"
    workspaces {
      name = "az-vm"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "extended"
}

resource "random_integer" "random_zone" {
  min = 1
  max = 3
}