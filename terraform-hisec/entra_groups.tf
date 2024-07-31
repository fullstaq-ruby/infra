resource "azuread_group" "infra-owners" {
  display_name             = "Fullstaq Ruby Infra Owners"
  owners                   = var.infra_owners_azure_group_members
  members                  = var.infra_owners_azure_group_members
  security_enabled         = true
  mail_enabled             = false
  external_senders_allowed = false
}

resource "azuread_group" "infra-maintainers" {
  display_name             = "Fullstaq Ruby Infra Maintainers"
  owners                   = var.infra_owners_azure_group_members
  members                  = var.infra_maintainers_azure_group_members
  security_enabled         = true
  mail_enabled             = false
  external_senders_allowed = false
}
