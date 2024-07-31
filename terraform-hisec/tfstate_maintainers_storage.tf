# If you change the names in this file, make sure you update terraform/backend.tf.

resource "azurerm_resource_group" "tfstate-infra-maintainers" {
  name     = "fullstaq-ruby-terraform"
  location = "westeurope"
}

resource "azurerm_storage_account" "tfstate-infra-maintainers" {
  name                            = "${var.storage_account_prefix}terraform"
  resource_group_name             = azurerm_resource_group.tfstate-infra-maintainers.name
  location                        = azurerm_resource_group.tfstate-infra-maintainers.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  default_to_oauth_authentication = true
  shared_access_key_enabled       = false

  tags = {
    description = "Terraform state storage for Infra Maintainers"
  }
}

resource "azurerm_storage_container" "tfstate-infra-maintainers" {
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.tfstate-infra-maintainers.name
}

# R/W access is needed so that Infra Owners can bootstrap the initial Terraform infra.
resource "azurerm_role_assignment" "tfstate-infra-maintainers-data-contrib-by-infra-owners" {
  scope                = azurerm_storage_account.tfstate-infra-maintainers.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.infra-owners.id
}

resource "azurerm_role_assignment" "tfstate-infra-maintainers-data-contrib-by-infra-maintainers" {
  scope                = azurerm_storage_account.tfstate-infra-maintainers.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.infra-maintainers.id
}
