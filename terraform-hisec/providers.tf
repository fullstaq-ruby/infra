terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 3.34.0"
    }
  }

  required_version = ">= 0.13"
}

provider "google" {
  project = var.gcloud_project
}
