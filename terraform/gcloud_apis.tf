resource "google_project_service" "iam-api" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "storage-api" {
  service = "storage.googleapis.com"
}
