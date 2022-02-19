variable "gcloud_project" {
  type    = string
  default = "fullstaq-ruby-hisec"
}

variable "azure_subscription_id" {
  type    = string
  default = "77fae31b-3e8a-4c34-910a-1ad75ec12cb9"
}

variable "azure_tenant_id" {
  type    = string
  default = "36205039-4c19-4879-a98a-ece51e361a19"
}

variable "azure_active_directory_owner" {
  type    = string
  default = "806ff7a2-62c0-46d4-87f8-c340e07794c6"
}

variable "azure_location_preferred_by_github_runners" {
  type = string
  # https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/issues/86#issuecomment-1032643774
  # https://docs.github.com/en/actions/reference/virtual-environments-for-github-hosted-runners#ip-addresses-of-github-hosted-runners
  # https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies
  default = "West US 2"
}

variable "infra_owners_azure_group_members" {
  type = list(string)
  default = [
    "cc17a6d2-f8e4-40cd-9074-6861768c8311", # Fabian Met
    "806ff7a2-62c0-46d4-87f8-c340e07794c6", # Hongli Lai
  ]
}

variable "infra_maintainers_azure_group_members" {
  type = list(string)
  default = [
    "cc17a6d2-f8e4-40cd-9074-6861768c8311", # Fabian Met
    "806ff7a2-62c0-46d4-87f8-c340e07794c6", # Hongli Lai
  ]
}
