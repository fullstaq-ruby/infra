resource "google_project_iam_member" "infra-ci-bot-deploy-apiserver" {
  project = var.gcloud_project
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.infra-ci-bot.email}"
}

resource "google_service_account_iam_member" "infra-ci-bot-deploy-apiserver" {
  service_account_id = google_service_account.apiserver.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.infra-ci-bot.email}"
}


resource "google_project_iam_member" "apiserver-error-reporting" {
  project = var.gcloud_project
  role    = "roles/errorreporting.writer"
  member  = "serviceAccount:${google_service_account.apiserver.email}"
}
