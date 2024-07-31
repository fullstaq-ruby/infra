terraform {
  backend "azurerm" {
    tenant_id       = "1907c1de-23e9-40f4-89ea-4adfabb7d409"
    subscription_id = "3ab8732c-429b-41e8-80a8-f46106e67e11"

    # Make sure the values below match the ones in terraform-hisec/tfstate_lowsec_storage.tf
    resource_group_name  = "fullstaq-ruby-terraform"
    storage_account_name = "fsruby2terraform"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_azuread_auth     = true
  }
}
