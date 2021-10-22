resource "google_project_iam_member" "server-edition-ci-bot-access-secrets" {
  depends_on = [google_project_service.secretmanager-api]
  project    = var.gcloud_project
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.server-edition-ci-bot.email}"
}
