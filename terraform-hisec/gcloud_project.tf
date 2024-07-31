resource "google_project" "server-edition" {
  name            = "Fullstaq Ruby Server Edition"
  project_id      = var.gcloud_project_id
  org_id          = var.gcloud_org_id
  billing_account = var.gcloud_billing_account_id
}
