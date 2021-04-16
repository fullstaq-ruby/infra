# Not yet removing it until DNS caches are flushed
resource "google_compute_global_address" "apt_gateway" {
  depends_on = [google_project_service.compute-api]
  name       = "fullstaq-ruby-packages-apt-gateway"
}

# Not yet removing it until DNS caches are flushed
resource "google_compute_global_address" "yum_gateway" {
  depends_on = [google_project_service.compute-api]
  name       = "fullstaq-ruby-packages-yum-gateway"
}

resource "google_compute_global_address" "gateway" {
  depends_on = [google_project_service.compute-api]
  name       = "fullstaq-ruby-packages-gateway"
}
