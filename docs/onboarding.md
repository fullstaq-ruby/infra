# Onboarding

Onboarding is to be done by someone with the [Infra Owner role](roles.md).

- [ ] Give access.
  - If Infra Maintainer: add to the [Github repo's members list](https://github.com/fullstaq-ruby/infra/settings/access).
  - If Infra Owner: add to the [Infra Owners team](https://github.com/orgs/fullstaq-ruby/teams/infra-owners).
- [ ] Add to the `fsruby-server-edition2` Google Cloud project.
  - If Infra Maintainer: assign roles "Editor", "Storage Admin".
  - If Infra Owner: assign roles "Owner", "Storage Admin".
- [ ] Add to Entra ID.
  - [ ] Create a (regular) user.
  - [ ] Add object ID to `terraform-hisec/variables.tf` -> `infra_owners_azure_group_members` or `infra_maintainers_azure_group_members`. Apply Terraform.
- [ ] Add to the [Members](members.md) document.
