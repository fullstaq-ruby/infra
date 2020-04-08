resource "google_container_registry" "registry" {
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = "${google_container_registry.registry.bucket_self_link}"
  role   = "roles/storage.objectViewer"
  members = ["allUsers"]
}
