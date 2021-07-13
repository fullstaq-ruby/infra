resource "google_container_registry" "registry" {
  depends_on = [google_project_service.containerregistry-api]
}

resource "google_storage_bucket_iam_binding" "container-registry-public-viewable" {
  bucket  = google_container_registry.registry.bucket_self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_storage_bucket_iam_binding" "container-registry-admins" {
  bucket = google_container_registry.registry.bucket_self_link
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.infra-ci-bot.email}",
    "serviceAccount:${google_service_account.server-edition-ci-bot.email}"
  ]
}
