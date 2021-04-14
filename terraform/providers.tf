terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.64.0"
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
