resource "google_project_service" "gcp_services" {
  count   = length(var.gcp_services)
  project = var.gcloud_project
  service = var.gcp_services[count.index]
  # (Optional) If true, services that are enabled and which depend on this service should also be disabled when this service is destroyed.
  # If false or unset, an error will be generated if any enabled services depend on this service when destroying it.
  disable_dependent_services = false
}
