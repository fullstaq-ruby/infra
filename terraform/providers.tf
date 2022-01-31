terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.64.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
  }

  required_version = ">= 0.13"
}

provider "google" {
  project = var.gcloud_project
}

provider "google-beta" {
  project = var.gcloud_project
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
  subscription_id     = var.azure_subscription_id
  tenant_id           = var.azure_tenant_id
}
