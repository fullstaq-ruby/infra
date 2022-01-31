resource "azurerm_resource_group" "fullstaq-ruby-server-edition" {
  name     = "fullstaq-ruby-server-edition"
  location = var.azure_location_preferred_by_github_runners
}

resource "azurerm_role_assignment" "server-edition-resource-group-owned-by-infra-owners" {
  scope                = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.fullstaq-ruby-server-edition.name}"
  role_definition_name = "Owner"
  principal_id         = azuread_group.infra-owners.object_id
}

resource "azurerm_role_assignment" "server-edition-resource-group-owned-by-infra-maintainers" {
  scope                = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.fullstaq-ruby-server-edition.name}"
  role_definition_name = "Owner"
  principal_id         = azuread_group.infra-maintainers.object_id
}
