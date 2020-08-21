resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"
}
