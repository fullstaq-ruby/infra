variable "gcloud_project" {
  default = "fullstaq-ruby"
}

variable "dns_name" {
  default = "fullstaqruby.org."
}

variable "globally_unique_resource_prefix" {
  default     = "fullstaq-ruby"
  description = "Prefix for naming resources that must have globally unique names, such as Cloud Storage buckets"
}

variable "gcloud_storage_location" {
  default = "US"
}

variable "kubernetes_region" {
  default = "us-east4"
}

variable "azure_subscription_id" {
  type    = string
  default = "77fae31b-3e8a-4c34-910a-1ad75ec12cb9"
}

variable "azure_tenant_id" {
  type    = string
  default = "36205039-4c19-4879-a98a-ece51e361a19"
}

variable "infra_owners_azure_group_object_id" {
  type    = string
  default = "3e5dac1c-5ca9-4623-92f5-aae6ecee4de5"
}

variable "infra_maintainers_azure_group_object_id" {
  type    = string
  default = "3281e765-1b4e-4420-8bd7-30ef3de9c8bc"
}

variable "azure_location_preferred_by_github_runners" {
  type = string
  # https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/issues/86#issuecomment-1032643774
  # https://docs.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners#ip-addresses-of-github-hosted-runners
  # https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies
  default = "West US 2"
}

variable "gcloud_storage_location_preferred_by_github_runners" {
  type = string
  # https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/issues/86#issuecomment-1032643774
  # https://docs.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners#ip-addresses-of-github-hosted-runners
  # https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies
  default = "US-EAST4"
}
