# Infrastructure as code & directory structure

We define as much infrastructure as possible in the form of code, using:

 * [Terraform](https://terraform.io)
 * Kubernetes YAML, managed with [Kustomize](https://kustomize.io/)

The infrastructure-as-code is stored in the following directories:

 * `terraform/` — Infrastructure administered by [Infra Maintainers](roles.md), except for resources inside Kubernetes. Most of the infrastructure is defined here.

 * `terraform-hisec/` — Infrastructure administered by [Infra Owners](roles.md). This covers for example resources in the `fullstaq-ruby-hisec` Google Cloud project.

   Because we don't expect the infrastructure in this directory to change very often, we've chosen — for security reasons — not to run Terraform in a CI/CD pipeline. This way we don't have to worry about the security of the CI/CD pipeline's service account. Instead, an [Infra Owner](roles.md) runs Terraform manually, using that person's personal Google Cloud credentials.

 * `kubernetes/` — Kubernetes resources administered by [Infra Maintainers](roles.md).

Note that not all infrastructure can, or (for security reasons) should, be managed via code. Learn more at [Infrastructure bootstrapping](infrastructure-bootstrapping.md).
