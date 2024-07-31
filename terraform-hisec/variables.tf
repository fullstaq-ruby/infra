variable "azure_tenant_id" {
  type    = string
  default = "1907c1de-23e9-40f4-89ea-4adfabb7d409"
}

variable "azure_subscription_id" {
  type    = string
  default = "3ab8732c-429b-41e8-80a8-f46106e67e11"
}

variable "tfstate_resource_group_name" {
  type    = string
  default = "fullstaq-ruby-terraform-hisec"
}

variable "tfstate_storage_account_name" {
  type    = string
  default = "fsrubyterraformhisec"
}

variable "storage_account_prefix" {
  type    = string
  default = "fsruby2"
}

variable "key_vault_prefix" {
  type    = string
  default = "fsruby2"
}

variable "gcloud_org_id" {
  type    = string
  default = "252249970036"
}

variable "gcloud_project_id" {
  type    = string
  default = "fsruby-server-edition2"
}

variable "gcloud_billing_account_id" {
  type    = string
  default = "018150-C9AFC8-E009BB"
}

variable "infra_owners_azure_group_members" {
  type = list(string)
  default = [
    "bd39226a-d395-46c3-a865-782111c5edc5", # Hongli Lai
  ]
}

variable "infra_maintainers_azure_group_members" {
  type = list(string)
  default = [
    "2f1efb75-a4a9-4b3c-aec5-a40b51fbfe86", # Hongli Lai infra-maintainer account
  ]
}
