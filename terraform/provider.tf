terraform {
  required_version = "1.14.9"
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.69.0"
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