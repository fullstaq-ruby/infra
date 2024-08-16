# Offboarding

Offboarding is to be done by someone with the [Infra Owner role](roles.md).

- [ ] Remove member from the [Github repo's members list](https://github.com/fullstaq-ruby/infra/settings/access).
- [ ] Remove member from the `fsruby-server-edition2` Google Cloud project.
- [ ] Remove member from `terraform-hisec/variables.tf`, both `infra_owners_azure_group_members` and `infra_maintainers_azure_group_members`. Apply Terraform.
- [ ] Rotate the shared access keys for the `fsruby2seredci1` Azure storage account.
  1. In the Azure portal, go to the `fsruby2seredci1` storage account -> Access keys.
  2. Click "Rotate key" for key1.
  3. Refresh Terraform state: run `pushd terraform && terraform refresh; popd`
  4. Install the new connection string as a Github Actions secret. See [Infrastructure bootstrapping](infrastructure-bootstrapping.md) -> "Populate Github Actions secrets and variables".
- [ ] Remove member from Entra ID.
- [ ] In the [Members](members.md) document, move member to the "Alumni" section.
