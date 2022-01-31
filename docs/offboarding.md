# Offboarding

Offboarding is to be done by someone with the [Infra Owner role](roles.md).

 - [ ] Remove member from the [Github repo's members list](https://github.com/fullstaq-labs/fullstaq-ruby-infra/settings/access).
 - [ ] Remove member from the `fullstaq-ruby` Google Cloud project.
 - [ ] Remove member from the `fullstaq-ruby-hisec` Google Cloud project.
 - [ ] Remove member from `terraform-hisec/variables.tf`, both `infra_owners_azure_group_members` and `infra_maintainers_azure_group_members`. Apply Terraform.
 - [ ] Rotate the shared access keys for the `fsrubyseredci1` Azure storage account.
    1. In the Azure portal, go to the `fsrubyseredci1` storage account -> Access keys.
    2. Click "Rotate key" for key1.
    3. Refresh Terraform state: run `pushd terraform && terraform refresh && popd`
    4. Install the new connection string as a Github Actions secret. See [Infrastructure bootstrapping](infrastructure-bootstrapping.md) -> "Populate Github Actions secrets" -> "Fetch the Azure storage account connection string..."
 - [ ] If member has a guest account in Fullstaq's Azure Active Directory, remove that guest account.
 - [ ] In the [Members](members.md) document, move member to the "Alumni" section.
