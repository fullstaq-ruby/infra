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

variable "storage_location" {
  default = "US"
}

variable "kubernetes_region" {
  default = "us-east4"
}
