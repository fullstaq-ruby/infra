# Infrastructure as code & directory structure

We define as much infrastructure as possible in the form of code, using:

 * [Terraform](https://terraform.io)
 * [Ansible](https://www.ansible.com/)
 * Github Actions

The infrastructure-as-code is stored in the following directories:

 * `terraform/` — Infrastructure administered by [Infra Maintainers](roles.md). Most of the cloud-side infrastructure is defined here.

 * `terraform-hisec/` — Infrastructure administered by [Infra Owners](roles.md). This covers for example sensitive resources such as the GPG signing key in Azure Key Vault, and the high-security Terraform state backend.

   Because we don't expect the infrastructure in this directory to change very often, we've chosen — for security reasons — not to run Terraform in a CI/CD pipeline. This way we don't have to worry about the security of any CI/CD pipeline credentials. Instead, an [Infra Owner](roles.md) runs Terraform manually, using their personal cloud credentials.

 * `ansible/` — Configuration of the backend VM (Caddy, the API server, Prometheus, and OS hardening). Administered by [Infra Maintainers](roles.md) and applied manually; see [Deployment guide](deploy.md).

 * `.github/workflows/apiserver.yml` — Builds and deploys the API server.

Note that not all infrastructure can, or (for security reasons) should, be managed via code. Learn more at [Infrastructure bootstrapping](infrastructure-bootstrapping.md).
