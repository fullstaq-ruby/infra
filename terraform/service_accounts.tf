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


resource "google_service_account" "server-edition-ci-bot" {
  depends_on   = [google_project_service.iam-api]
  account_id   = "server-edition-ci-bot"
  display_name = "Server Edition CI bot"
}

resource "google_service_account_key" "server-editions-ci-bot-sa-key" {
  service_account_id = google_service_account.server-edition-ci-bot.name
}
