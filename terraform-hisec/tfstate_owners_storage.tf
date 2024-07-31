resource "azurerm_role_assignment" "tfstate-infra-owners-data-owned-by-infra-owners" {
  scope                = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.tfstate_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.tfstate_storage_account_name}"
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_group.infra-owners.id
}
