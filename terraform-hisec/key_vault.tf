resource "azurerm_key_vault" "infra-owners" {
  tenant_id                 = var.azure_tenant_id
  resource_group_name       = azurerm_resource_group.infra-owners.name
  location                  = azurerm_resource_group.infra-owners.location
  name                      = "${var.key_vault_prefix}infraowners"
  sku_name                  = "standard"
  enable_rbac_authorization = true
  tags = {
    description = "Key Vault for Infra Owners"
  }
}

resource "azurerm_role_assignment" "infra-owners-kv-admin-by-infra-owners" {
  scope                = azurerm_key_vault.infra-owners.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_group.infra-owners.id
}


resource "azurerm_key_vault_secret" "server-edition-gpg-priv-key" {
  key_vault_id = azurerm_key_vault.infra-owners.id
  name         = "server-edition-gpg-private-key"
  value        = "initial value"

  lifecycle {
    # Value is managed outside Terraform, populated manually
    ignore_changes = [value, tags]
  }
}

resource "azurerm_role_assignment" "server-edition-gpg-priv-key-readable-by-github-ci-test" {
  scope                = azurerm_key_vault_secret.server-edition-gpg-priv-key.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.server-edition-github-ci-test.id
}

resource "azurerm_role_assignment" "server-edition-gpg-priv-key-readable-by-github-ci-deploy" {
  scope                = azurerm_key_vault_secret.server-edition-gpg-priv-key.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.server-edition-github-ci-deploy.id
}
