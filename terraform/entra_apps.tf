data "azuread_group" "infra-maintainers" {
  display_name               = "Fullstaq Ruby Infra Maintainers"
  include_transitive_members = true
}

resource "azuread_application" "caddy" {
  display_name = "Caddy"
  owners       = data.azuread_group.infra-maintainers.members
}

resource "azuread_service_principal" "caddy" {
  client_id = azuread_application.caddy.client_id
  owners    = data.azuread_group.infra-maintainers.members
  feature_tags {
    enterprise = true
  }
}

resource "azuread_service_principal_password" "caddy" {
  service_principal_id = azuread_service_principal.caddy.object_id
}
