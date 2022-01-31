terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.34.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.18.0"
    }
  }

  required_version = ">= 0.13"
}

provider "google" {
  project = var.gcloud_project
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}
