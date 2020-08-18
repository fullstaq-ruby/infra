terraform {
  backend "gcs" {
    bucket = "fullstaq-ruby-infra-hisec-terraform-state"
    prefix = "terraform/state"
  }
}
