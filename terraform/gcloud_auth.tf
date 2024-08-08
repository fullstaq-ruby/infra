resource "google_iam_workload_identity_pool" "github-ci-test" {
  depends_on                = [google_project_service.iam-api]
  workload_identity_pool_id = "github-ci-test"
}

resource "google_iam_workload_identity_pool_provider" "github-ci-test" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-ci-test.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-ci-test"
  display_name                       = "Github CI (test)"
  attribute_condition                = "assertion.repository_owner == 'fullstaq-ruby' && assertion.environment == 'test'"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.environment"      = "assertion.environment"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}


resource "google_iam_workload_identity_pool" "github-ci-deploy" {
  depends_on                = [google_project_service.iam-api]
  workload_identity_pool_id = "github-ci-deploy"
}

resource "google_iam_workload_identity_pool_provider" "github-ci-deploy" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-ci-deploy.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-ci-deploy"
  display_name                       = "Github CI (deploy)"
  attribute_condition                = "assertion.repository_owner == 'fullstaq-ruby' && assertion.environment == 'deploy'"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.environment"      = "assertion.environment"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
