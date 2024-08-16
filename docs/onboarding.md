# Onboarding

Onboarding is to be done by someone with the [Infra Owner role](roles.md).

- [ ] Add member to the [Github repo's members list](https://github.com/fullstaq-ruby/infra/settings/access).
  - If member is an Infra Maintainer: assign "Maintain" role.
  - If member is an Infra Owner: assign "Admin" role.
- [ ] Add member to the `fsruby-server-edition2` Google Cloud project.
  - If member is an Infra Maintainer: assign roles "Editor", "Storage Admin".
  - If member is an Infra Owner: assign roles "Owner", "Storage Admin".
- Add member to Entra ID.
  - [ ] Create a (regular) user.
  - [ ] Add object ID to `terraform-hisec/variables.tf` -> `infra_owners_azure_group_members` or `infra_maintainers_azure_group_members`. Apply Terraform.
- [ ] Add member to the [Members](members.md) document.
