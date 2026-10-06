terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Discovery should not request subscription-level provider registration.
  resource_provider_registrations = "none"
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "lab" {
  name = "rg-hv-identity-lab"
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "resource_group_name" {
  value = data.azurerm_resource_group.lab.name
}

output "resource_group_location" {
  value = data.azurerm_resource_group.lab.location
}

output "resource_group_tags" {
  value = data.azurerm_resource_group.lab.tags
}
