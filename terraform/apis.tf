resource "google_project_service" "compute-api" {
  project = var.gcloud_project
  service = "compute.googleapis.com"
}

resource "google_project_service" "container-api" {
  project = var.gcloud_project
  service = "container.googleapis.com"
}

resource "google_project_service" "containerregistry-api" {
  project = var.gcloud_project
  service = "containerregistry.googleapis.com"
}

resource "google_project_service" "dns-api" {
  project = var.gcloud_project
  service = "dns.googleapis.com"
}

resource "google_project_service" "servicenetworking-api" {
  project = var.gcloud_project
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "storage-api" {
  project = var.gcloud_project
  service = "storage.googleapis.com"
}

resource "google_project_service" "storage-component-api" {
  project = var.gcloud_project
  service = "storage-component.googleapis.com"
}

resource "google_project_service" "iam-api" {
  project = var.gcloud_project
  service = "iam.googleapis.com"
}

