terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.1"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 5.38.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.1"
    }
  }

  required_version = ">= 1.5"
}

provider "google" {
  project = var.gcloud_project_id
}

provider "azurerm" {
  features {}

  tenant_id           = var.azure_tenant_id
  subscription_id     = var.azure_subscription_id
  storage_use_azuread = true
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}
