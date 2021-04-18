resource "google_service_account" "server-edition-ci-bot" {
  depends_on   = [google_project_service.iam-api]
  account_id   = "server-edition-ci-bot"
  display_name = "Server Edition CI bot"
}

resource "google_service_account_key" "server-editions-ci-bot-sa-key" {
  service_account_id = google_service_account.server-edition-ci-bot.name
}
