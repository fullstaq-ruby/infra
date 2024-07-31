terraform {
  backend "azurerm" {
    tenant_id            = "1907c1de-23e9-40f4-89ea-4adfabb7d409"
    subscription_id      = "3ab8732c-429b-41e8-80a8-f46106e67e11"
    resource_group_name  = "fullstaq-ruby-terraform-hisec"
    storage_account_name = "fsrubyterraformhisec"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_azuread_auth     = true
  }
}
