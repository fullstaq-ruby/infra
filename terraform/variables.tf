variable "azure_subscription_id" {
  type    = string
  default = "3ab8732c-429b-41e8-80a8-f46106e67e11"
}

variable "azure_tenant_id" {
  type    = string
  default = "1907c1de-23e9-40f4-89ea-4adfabb7d409"
}

variable "gcloud_project_id" {
  type    = string
  default = "fsruby-server-edition2"
}

variable "dns_name" {
  type    = string
  default = "fullstaqruby.org"
}

variable "storage_account_prefix" {
  type    = string
  default = "fsruby2"
}

variable "gcloud_bucket_prefix" {
  type    = string
  default = "fsruby"
}

variable "gcloud_storage_location" {
  type    = string
  default = "US"
}

variable "azure_location_preferred_by_github_runners" {
  type = string
  # https://github.com/fullstaq-ruby/server-edition/issues/86#issuecomment-1032643774
  # https://docs.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners#ip-addresses-of-github-hosted-runners
  # https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies
  default = "West US 2"
}

variable "gcloud_storage_location_preferred_by_github_runners" {
  type = string
  # https://github.com/fullstaq-ruby/server-edition/issues/86#issuecomment-1032643774
  # https://docs.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners#ip-addresses-of-github-hosted-runners
  # https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies
  default = "US-EAST4"
}

variable "backend_server_ipv4" {
  type    = string
  default = "157.90.113.138"
}

variable "backend_server_ipv6" {
  type    = string
  default = "2a01:4f8:1c1c:7ac0::1"
}

variable "key_vault_prefix" {
  type    = string
  default = "fsruby2"
}
