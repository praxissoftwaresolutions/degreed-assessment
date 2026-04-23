terraform {
  required_version = "1.14.9"
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.69.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
  cloud {
    organization = "MRC-Legacy"
    workspaces {
      name = "testingonly"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli = false
}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}