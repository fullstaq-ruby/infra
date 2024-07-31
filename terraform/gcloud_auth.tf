resource "google_iam_workload_identity_pool" "github" {
  depends_on                = [google_project_service.iam-api]
  workload_identity_pool_id = "github"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "Github"
  attribute_condition                = "assertion.repository_owner == 'fullstaq-ruby'"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}


resource "google_service_account" "server-edition-ci-bot" {
  depends_on   = [google_project_service.iam-api]
  account_id   = "server-edition-ci-bot"
  display_name = "Server Edition CI bot"
}

resource "google_service_account_key" "server-edition-ci-bot-sa-key" {
  service_account_id = google_service_account.server-edition-ci-bot.name
}


# resource "google_service_account" "infra-ci-bot" {
#   depends_on   = [google_project_service.iam-api]
#   account_id   = "infra-ci-bot"
#   display_name = "Infrastructure CI bot"
# }

# resource "google_service_account_key" "infra-ci-bot-sa-key" {
#   service_account_id = google_service_account.infra-ci-bot.name
# }
