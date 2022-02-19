resource "google_storage_bucket" "server-edition-ci-artifacts" {
  depends_on                  = [google_project_service.storage-api]
  name                        = "${var.globally_unique_resource_prefix}-server-edition-ci-artifacts"
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = var.gcloud_storage_location_preferred_by_github_runners

  lifecycle_rule {
    condition {
      age = "30"
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_binding" "server-edition-ci-artifacts-public-viewable" {
  bucket  = google_storage_bucket.server-edition-ci-artifacts.self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_storage_bucket_iam_binding" "server-edition-ci-artifacts-writable-by-ci-cd" {
  bucket  = google_storage_bucket.server-edition-ci-artifacts.self_link
  role    = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.server-edition-ci-bot.email}"]
}
