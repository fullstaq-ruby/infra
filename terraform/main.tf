resource "google_compute_global_address" "apt_gateway" {
  name = "fullstaq-ruby-packages-apt-gateway"
}

resource "google_compute_global_address" "yum_gateway" {
  name = "fullstaq-ruby-packages-yum-gateway"
}

resource "transip_dns_record" "apt-gateway" {
  domain  = "fullstaqruby.org"
  name    = "apt"
  type    = "A"
  content = ["${google_compute_global_address.apt_gateway.address}"]
}

resource "transip_dns_record" "yum-gateway" {
  domain  = "fullstaqruby.org"
  name    = "yum"
  type    = "A"
  content = ["${google_compute_global_address.yum_gateway.address}"]
}
