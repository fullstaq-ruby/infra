provider "google" {
  version = "~> 2.11"
  project = "${var.gcloud_project}"
}

resource "google_compute_global_address" "apt_gateway" {
  name = "fullstaq-ruby-packages-apt-gateway"
}

resource "google_compute_global_address" "yum_gateway" {
  name = "fullstaq-ruby-packages-yum-gateway"
}

resource "google_dns_record_set" "website" {
  name = "@.fullstaqruby.org."
  type = "A"
  ttl  = 86400
  managed_zone = "fullstaq-ruby-org"
  # Github Pages IPs
  rrdatas = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}

resource "google_dns_record_set" "website_google_verification" {
  name = "@.fullstaqruby.org."
  type = "TXT"
  ttl  = 86400
  managed_zone = "fullstaq-ruby-org"
  rrdatas = ["google-site-verification=usrLESAOrudLzVFrFcTxPGqMikectAoaWT8aJe0cLFc"]
}

resource "google_dns_record_set" "website_dmarc" {
  name = "_dmarc.fullstaqruby.org."
  type = "TXT"
  ttl  = 86400
  managed_zone = "fullstaq-ruby-org"
  rrdatas = ["v=DMARC1; p=none;"]
}

resource "google_dns_record_set" "apt_gateway" {
  name = "apt.fullstaqruby.org."
  type = "A"
  ttl  = 86400
  managed_zone = "fullstaq-ruby-org"
  rrdatas = ["${google_compute_global_address.apt_gateway.address}"]
}

resource "google_dns_record_set" "yum_gateway" {
  name = "yum.fullstaqruby.org."
  type = "A"
  ttl  = 86400
  managed_zone = "fullstaq-ruby-org"
  rrdatas = ["${google_compute_global_address.yum_gateway.address}"]
}
