# Roles

For security reasons, we define two roles in the infrastructure team. These roles are not mutually exclusive.

 - **Infra Owners** own resource containers, especially sensitive resources, and resources that cannot be securely shared with many people. For example, they own the Google Cloud project, the TransIP (domain registrar) account and the GPG private key.

   Infra Owners are also responsible for [onboarding](onboarding.md) and [offboarding](offboarding.md) team members.

   People in this role can potentially delete everything, so very few people are assigned this role. Assignment only changes during exceptional events, e.g. when an owner leaves.

   Minimum number of owners: 2.

 - **Infra Maintainers** can read, write, update and delete less-sensitive resources within resource containers. For example, they can create, change or delete Google Cloud Storage buckets, virtual machines.

   Minimum number of maintainers: 1.
