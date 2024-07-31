resource "azurerm_role_assignment" "subscription-owned-by-infra-owners" {
  scope                = "/subscriptions/${var.azure_subscription_id}"
  role_definition_name = "Owner"
  principal_id         = azuread_group.infra-owners.id
}
