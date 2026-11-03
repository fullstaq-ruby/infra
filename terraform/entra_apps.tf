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

# Entra ID gives client secrets a 2-year lifetime by default. Rotate the Caddy
# secret yearly so it is replaced well before it expires; otherwise Caddy's
# ACME DNS-01 challenge silently fails and the apt/yum TLS certificates lapse.
# After this clock trips, `terraform apply` creates a new secret and the Ansible
# playbook must be re-run to push it to the VM.
resource "time_rotating" "caddy_password" {
  rotation_days = 365
}

resource "azuread_service_principal_password" "caddy" {
  service_principal_id = azuread_service_principal.caddy.object_id

  rotate_when_changed = {
    rotation = time_rotating.caddy_password.id
  }
}
