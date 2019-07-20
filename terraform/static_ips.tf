resource "google_compute_global_address" "apt_gateway" {
  name = "fullstaq-ruby-packages-apt-gateway"
}

resource "google_compute_global_address" "yum_gateway" {
  name = "fullstaq-ruby-packages-yum-gateway"
}
