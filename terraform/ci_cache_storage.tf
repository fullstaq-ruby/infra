resource "azurerm_storage_account" "server-edition-ci" {
  name                     = "fsrubyseredci1"
  resource_group_name      = "fullstaq-ruby-server-edition"
  location                 = var.azure_location_preferred_by_github_runners
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  is_hns_enabled           = false

  blob_properties {
    last_access_time_enabled = true
  }
}

resource "azurerm_storage_container" "server-edition-ci-cache" {
  name                  = "server-edition-ci-cache"
  storage_account_name  = azurerm_storage_account.server-edition-ci.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "server-edition-ci-cache-expiry" {
  storage_account_id = azurerm_storage_account.server-edition-ci.id

  rule {
    name    = "expire-old-entries"
    enabled = true

    filters {
      prefix_match = ["${azurerm_storage_container.server-edition-ci-cache.name}/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_last_access_time_greater_than = "90"
      }
    }
  }
}

resource "azurerm_role_assignment" "server-edition-ci-cache-accessible-by-infra-owners" {
  scope                = azurerm_storage_container.server-edition-ci-cache.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.infra_owners_azure_group_object_id
}

resource "azurerm_role_assignment" "server-edition-ci-cache-owned-by-infra-maintainers" {
  scope                = azurerm_storage_container.server-edition-ci-cache.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.infra_maintainers_azure_group_object_id
}
