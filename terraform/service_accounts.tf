resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
  display_name = "Kubernetes"
}

resource "google_project_iam_member" "kubernetes-logwriter" {
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}

resource "google_project_iam_member" "kubernetes-metricwriter" {
  role = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}

resource "google_project_iam_member" "kubernetes-monitoring-viewer" {
  role = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}
