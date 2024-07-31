resource "azurerm_key_vault" "infra-maintainers" {
  tenant_id                 = var.azure_tenant_id
  resource_group_name       = "fullstaq-ruby-infra-maintainers"
  location                  = "westeurope"
  name                      = "${var.key_vault_prefix}inframaint"
  sku_name                  = "standard"
  enable_rbac_authorization = true
  tags = {
    description = "Key Vault for Infra Maintainers"
  }
}

resource "azurerm_role_assignment" "infra-maintainers-kv-admin-by-infra-maintainers" {
  scope                = azurerm_key_vault.infra-maintainers.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_group.infra-maintainers.id
}


resource "azurerm_key_vault_secret" "caddy-client-id" {
  key_vault_id = azurerm_key_vault.infra-maintainers.id
  name         = "caddy-sp-client-id"
  value        = azuread_application.caddy.client_id
}

resource "azurerm_key_vault_secret" "caddy-client-secret" {
  key_vault_id = azurerm_key_vault.infra-maintainers.id
  name         = "caddy-sp-client-secret"
  value        = azuread_service_principal_password.caddy.value
}

resource "azurerm_role_assignment" "caddy-client-id-readable-by-infra-maintainers" {
  scope                = azurerm_key_vault_secret.caddy-client-id.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_group.infra-maintainers.id
}

resource "azurerm_role_assignment" "caddy-client-secret-readable-by-infra-maintainers" {
  scope                = azurerm_key_vault_secret.caddy-client-secret.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_group.infra-maintainers.id
}
