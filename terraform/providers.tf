provider "google" {
  version = "~> 2.11"
  project     = "${var.gcloud_project}"
}

provider "transip" {
  account_name = "${var.transip_account}"
  private_key  = "${var.transip_private_key}"
}
