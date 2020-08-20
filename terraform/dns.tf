resource "google_dns_managed_zone" "fullstaqruby_org" {
  name = "fullstaqruby-org"
  dns_name = "fullstaqruby.org."
  dnssec_config {
    state = "on"
  }
}

resource "google_dns_record_set" "website" {
  name = google_dns_managed_zone.fullstaqruby_org.dns_name
  type = "A"
  ttl  = 86400
  managed_zone = google_dns_managed_zone.fullstaqruby_org.name
  # Github Pages IPs
  rrdatas = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}

resource "google_dns_record_set" "website_google_verification" {
  name = google_dns_managed_zone.fullstaqruby_org.dns_name
  type = "TXT"
  ttl  = 86400
  managed_zone = google_dns_managed_zone.fullstaqruby_org.name
  rrdatas = ["google-site-verification=usrLESAOrudLzVFrFcTxPGqMikectAoaWT8aJe0cLFc"]
}

resource "google_dns_record_set" "website_dmarc" {
  name = "_dmarc.${google_dns_managed_zone.fullstaqruby_org.dns_name}"
  type = "TXT"
  ttl  = 86400
  managed_zone = google_dns_managed_zone.fullstaqruby_org.name
  rrdatas = ["\"v=DMARC1;\" \"p=none;\""]
}

resource "google_dns_record_set" "apt_gateway" {
  name = "apt.${google_dns_managed_zone.fullstaqruby_org.dns_name}"
  type = "A"
  ttl  = 86400
  managed_zone = google_dns_managed_zone.fullstaqruby_org.name
  rrdatas = [google_compute_global_address.apt_gateway.address]
}

resource "google_dns_record_set" "yum_gateway" {
  name = "yum.${google_dns_managed_zone.fullstaqruby_org.dns_name}"
  type = "A"
  ttl  = 86400
  managed_zone = google_dns_managed_zone.fullstaqruby_org.name
  rrdatas = [google_compute_global_address.yum_gateway.address]
}
