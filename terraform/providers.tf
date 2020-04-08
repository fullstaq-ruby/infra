provider "google" {
  version = "~> 3.16.0"
  project = "${var.gcloud_project}"
}

provider "google-beta" {
  version = "~> 3.16.0"
  project = "${var.gcloud_project}"
}
