resource "google_service_account" "kubernetes" {
  depends_on   = [google_project_service.iam-api]
  account_id   = "kubernetes"
  display_name = "Kubernetes"
}

resource "google_project_iam_member" "kubernetes-logwriter" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}

resource "google_project_iam_member" "kubernetes-metricwriter" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}

resource "google_project_iam_member" "kubernetes-monitoring-viewer" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}


resource "google_service_account" "github-actions" {
  depends_on   = [google_project_service.iam-api]
  account_id   = "github-actions"
  display_name = "Github Actions"
}

resource "google_service_account_key" "github-actions-sa-key" {
  service_account_id = google_service_account.github-actions.name
}
