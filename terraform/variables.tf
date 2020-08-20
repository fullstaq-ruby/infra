variable "gcloud_project" {
  default = "fullstaq-ruby"
}

variable "gcp_services" {
  description = "GCP services to be enabled"
  type        = list
}
