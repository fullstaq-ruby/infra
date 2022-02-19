# Onboarding

Onboarding is to be done by someone with the [Infra Owner role](roles.md).

**Note**: new Infra Owners must be Fullstaq employees. Only Fullstaq employees are allowed sufficient access to Azure Active Directory.

 - [ ] Add member to the [Github repo's members list](https://github.com/fullstaq-labs/fullstaq-ruby-infra/settings/access).
    - If member is an Infra Maintainer: assign "Maintain" role.
    - If member is an Infra Owner: assign "Admin" role.
 - [ ] Add member to the `fullstaq-ruby` Google Cloud project.
    - If member is an Infra Maintainer: assign roles "Editor", "Storage Admin".
    - If member is an Infra Owner: assign roles "Owner", "Storage Admin".
 - Add member to Fullstaq's Azure Active Directory.
    - If member is an Infra Maintainer:
       - [ ] Add as a guest.
       - [ ] Add object ID to `terraform-hisec/variables.tf` -> `infra_maintainers_azure_group_members`. Apply Terraform.
    - If member is an Infra Owner:
       - [ ] Verify member is a Fullstaq employee. Employees are already in Azure Active Directory. Non-employees are not allowed to be Infra Owners.
       - [ ] Add object ID to `terraform-hisec/variables.tf` -> `infra_owners_azure_group_members`. Apply Terraform.
 - [ ] If member is an Infra Owner: add member to the `fullstaq-ruby-hisec` Google Cloud project. Assign "Owner" role.
 - [ ] Add member to the [Members](members.md) document.
