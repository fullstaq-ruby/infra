resource "google_container_cluster" "autopilot" {
  depends_on       = [google_project_service.container-api]
  name             = "fullstaq-ruby-autopilot"
  location         = var.kubernetes_region
  enable_autopilot = true

  # Use VPC-native IPs
  ip_allocation_policy {}

  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}

resource "google_project_iam_member" "kubernetes-editable-by-apiserver" {
  project = var.gcloud_project
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.apiserver.email}"
}
