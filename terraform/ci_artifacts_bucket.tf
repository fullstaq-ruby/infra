resource "google_storage_bucket" "server-edition-ci-artifacts" {
  depends_on         = [google_project_service.storage-api]
  name               = "${var.globally_unique_resource_prefix}-server-edition-ci-artifacts"
  force_destroy      = true
  bucket_policy_only = true

  # All Github-hosted runners are located in the US,
  # of which two are located in Virginia. So we
  # pick Google Cloud's Virginia region too.
  # https://docs.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners#ip-addresses-of-github-hosted-runners
  # https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies
  location = "US-EAST4"

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
