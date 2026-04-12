# Terraform Provider for Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.65.0"
    }
    # Required for the naming module
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.1"
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

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [var.workload_suffix, var.env_suffix]
}

module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = module.naming.resource_group.name
  location = var.location

  tags = var.tags
}
