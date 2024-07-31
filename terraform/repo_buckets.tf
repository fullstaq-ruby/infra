resource "google_storage_bucket" "server-edition-apt-repo" {
  depends_on                  = [google_project_service.storage-api]
  name                        = "${var.gcloud_bucket_prefix}-server-edition-apt-repo"
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = var.gcloud_storage_location
}

resource "google_storage_bucket_iam_binding" "server-edition-apt-repo-public-viewable" {
  bucket  = google_storage_bucket.server-edition-apt-repo.self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_storage_bucket_iam_binding" "server-edition-apt-repo-writable-by-server-edition-ci-bot" {
  bucket  = google_storage_bucket.server-edition-apt-repo.self_link
  role    = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.server-edition-ci-bot.email}"]
}


resource "google_storage_bucket" "server-edition-yum-repo" {
  depends_on                  = [google_project_service.storage-api]
  name                        = "${var.gcloud_bucket_prefix}-server-edition-yum-repo"
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = var.gcloud_storage_location
}

resource "google_storage_bucket_iam_binding" "server-edition-yum-repo-public-viewable" {
  bucket  = google_storage_bucket.server-edition-yum-repo.self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_storage_bucket_iam_binding" "server-edition-yum-repo-writable-by-server-edition-ci-bot" {
  bucket  = google_storage_bucket.server-edition-yum-repo.self_link
  role    = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.server-edition-ci-bot.email}"]
}
