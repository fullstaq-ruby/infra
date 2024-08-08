data "azuread_service_principal" "server-edition-github-ci-test" {
  display_name = "Server Edition Github CI (test)"
}

data "azuread_service_principal" "server-edition-github-ci-deploy" {
  display_name = "Server Edition Github CI (deploy)"
}


resource "azurerm_storage_account" "server-edition-ci" {
  name                     = "${var.storage_account_prefix}seredci1"
  resource_group_name      = "fullstaq-ruby-infra-maintainers"
  location                 = var.azure_location_preferred_by_github_runners
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false

  blob_properties {
    last_access_time_enabled = true
  }

  tags = {
    description = "Server Edition CI storage"
  }
}


resource "azurerm_storage_container" "server-edition-ci-artifacts" {
  name                  = "server-edition-ci-artifacts"
  storage_account_name  = azurerm_storage_account.server-edition-ci.name
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "server-edition-ci-storage-expiry" {
  storage_account_id = azurerm_storage_account.server-edition-ci.id

  rule {
    name    = "expire-old-artifacts"
    enabled = true
    filters {
      prefix_match = ["${azurerm_storage_container.server-edition-ci-artifacts.name}/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = "30"
      }
    }
  }

  rule {
    name    = "expire-old-caches"
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

resource "azurerm_role_assignment" "server-edition-ci-artifacts-owned-by-infra-maintainers" {
  scope                = azurerm_storage_container.server-edition-ci-artifacts.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azuread_group.infra-maintainers.id
}

resource "azurerm_role_assignment" "server-edition-ci-artifacts-writable-by-github-ci-test" {
  scope                = azurerm_storage_container.server-edition-ci-artifacts.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.server-edition-github-ci-test.id
}

resource "azurerm_role_assignment" "server-edition-ci-artifacts-readable-by-github-ci-deploy" {
  scope                = azurerm_storage_container.server-edition-ci-artifacts.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azuread_service_principal.server-edition-github-ci-deploy.id
}


resource "azurerm_storage_container" "server-edition-ci-cache" {
  name                  = "server-edition-ci-cache"
  storage_account_name  = azurerm_storage_account.server-edition-ci.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "server-edition-ci-cache-owned-by-infra-maintainers" {
  scope                = azurerm_storage_container.server-edition-ci-cache.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azuread_group.infra-maintainers.id
}

resource "azurerm_role_assignment" "server-edition-ci-cache-writable-by-github-ci-test" {
  scope                = azurerm_storage_container.server-edition-ci-cache.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.server-edition-github-ci-test.id
}


resource "google_storage_bucket" "server-edition-ci-artifacts" {
  depends_on                  = [google_project_service.storage-api]
  name                        = "${var.gcloud_bucket_prefix}-server-edition-ci-artifacts"
  force_destroy               = true
  uniform_bucket_level_access = true
  location                    = var.gcloud_storage_location_preferred_by_github_runners

  lifecycle_rule {
    condition {
      age = "30"
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_binding" "server-edition-ci-artifacts-public-viewable" {
  bucket  = google_storage_bucket.server-edition-ci-artifacts.self_link
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}

resource "google_storage_bucket_iam_binding" "server-edition-ci-artifacts-writable-by-github-ci-test" {
  bucket  = google_storage_bucket.server-edition-ci-artifacts.self_link
  role    = "roles/storage.objectAdmin"
  members = ["principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-ci-test.name}/attribute.repository/fullstaq-ruby/server-edition"]
}
