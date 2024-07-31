resource "azurerm_resource_group" "infra-owners" {
  name     = "fullstaq-ruby-infra-owners"
  location = "westeurope"
}

resource "azurerm_role_assignment" "infra-owners-resource-group-owned-by-infra-owners" {
  scope                = azurerm_resource_group.infra-owners.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.infra-owners.id
}

resource "azurerm_resource_group" "infra-maintainers" {
  name     = "fullstaq-ruby-infra-maintainers"
  location = "westeurope"
}

resource "azurerm_role_assignment" "infra-maintainers-rg-owned-by-infra-maintainers" {
  scope                = azurerm_resource_group.infra-maintainers.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.infra-maintainers.id
}
