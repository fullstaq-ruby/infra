resource "google_storage_bucket" "server-edition-apt-repo" {
  depends_on         = [google_project_service.storage-api]
  name               = "${var.globally_unique_resource_prefix}-server-edition-apt-repo"
  force_destroy      = true
  bucket_policy_only = true
  location           = "US-EAST4"
}

resource "google_storage_bucket_iam_binding" "server-edition-apt-repo-public-viewable" {
  bucket  = google_storage_bucket.server-edition-apt-repo.self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}


resource "google_storage_bucket" "server-edition-yum-repo" {
  depends_on         = [google_project_service.storage-api]
  name               = "${var.globally_unique_resource_prefix}-server-edition-yum-repo"
  force_destroy      = true
  bucket_policy_only = true
  location           = "US-EAST4"
}

resource "google_storage_bucket_iam_binding" "server-edition-yum-repo-public-viewable" {
  bucket  = google_storage_bucket.server-edition-yum-repo.self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}
