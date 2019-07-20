provider "google" {
  version = "~> 2.11"
  project = "${var.gcloud_project}"
}

provider "google-beta" {
  version = "~> 2.11"
  project = "${var.gcloud_project}"
}
