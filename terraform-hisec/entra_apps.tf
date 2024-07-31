resource "azuread_application" "server-edition-github-ci-test" {
  display_name = "Server Edition Github CI (test)"
  owners       = var.infra_owners_azure_group_members
}

resource "azuread_application_federated_identity_credential" "server-edition-github-ci-test" {
  application_id = azuread_application.server-edition-github-ci-test.id
  display_name   = "server-edition-github-ci-test"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:fullstaq-ruby/server-edition:environment:test"
}

resource "azuread_service_principal" "server-edition-github-ci-test" {
  client_id = azuread_application.server-edition-github-ci-test.client_id
  owners    = var.infra_owners_azure_group_members
  feature_tags {
    enterprise = true
  }
}


resource "azuread_application" "server-edition-github-ci-deploy" {
  display_name = "Server Edition Github CI (deploy)"
  owners       = var.infra_owners_azure_group_members
}

resource "azuread_application_federated_identity_credential" "server-edition-github-ci-deploy" {
  application_id = azuread_application.server-edition-github-ci-deploy.id
  display_name   = "server-edition-github-ci-deploy"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:fullstaq-ruby/server-edition:environment:deploy"
}

resource "azuread_service_principal" "server-edition-github-ci-deploy" {
  client_id = azuread_application.server-edition-github-ci-deploy.client_id
  owners    = var.infra_owners_azure_group_members
  feature_tags {
    enterprise = true
  }
}
