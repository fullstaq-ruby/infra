resource "google_compute_global_address" "gateway" {
  depends_on = [google_project_service.compute-api]
  name       = "fullstaq-ruby-packages-gateway"
}
