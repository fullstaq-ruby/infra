## Infrastructure overview

The following diagram shows which infrastructure components exist and how they relate to each other. The bubbles on the corner of a component shows which [role](roles.md) administers that component.

![Infrastructure overview diagram](infrastructure-overview.svg)

## Google Cloud projects

 * Administrated by role: Infra Owners

All Google Cloud resources are contained in two projects:

 - `fullstaq-ruby` for normal resources. Infra Maintainers have full access to all resources _inside_ this project.
 - `fullstaq-ruby-hisec` for especially sensitive resources. Only Infra Owners have access to the resources inside this project.

## Terraform state (normal)

 * Administered by role: Infra Maintainers

The Terraform state for normal infrastructure is stored in a Google Cloud Storage bucket, inside the `fullstaq-ruby` project.

## Terraform state (hisec)

 * Administered by role: Infra Owners

The Terraform state for sensitive infrastructure is stored in a Google Cloud Storage bucket, inside the `fullstaq-ruby-hisec` project.

## Server Edition CI artifacts store

 * Administered by role: Infra Maintainers

The Server Edition's CI/CD system stores artifacts in this bucket, for the purpose of implementing [resumption](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/blob/main/dev-handbook/ci-cd-resumption.md). Objects in this bucket only live for 14 days.

## Server Edition APT & YUM repo buckets

 * Administered by role: Infra Maintainers

The Server Edition's APT and YUM repositories are stored inside these buckets. These buckets are publicly readable.

Users don't access these buckets directly. Instead, they access `apt.fullstaqruby.org` and `yum.fullstaqruby.org` (served by the Nginx web servers), which redirect to these buckets.

## Container registry

 * Administered by role: Infra Maintainers

The `fullstaq-ruby` project has a container registry, which is used by developers' CI/CD systems, for example to store [build environment images](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/blob/main/dev-handbook/build-environments.md).

## DNS, static IPs, Ingresses

 * Administered by role: Infra Maintainers

All DNS entries for `fullstaqruby.org` are managed through Google Cloud DNS, inside the `fullstaq-ruby` project.

 * `fullstaqruby.org` points to Github Pages, where we host the [website](https://github.com/fullstaq-labs/fullstaq-ruby-website).
 * `{apt,yum}.fullstaqruby.org` point to Nginx's two virtual hosts, via two different static IPs and two different Kubernetes Ingresses.

## Nginx web servers, Kubernetes node pools

 * Administered by role: Infra Maintainers

We run two Nginx instances. These web servers' only purpose is to redirect traffic. Users interact primarily with `{apt,yum}.fullstaqruby.org` instead of with the APT and YUM repo buckets directly. This decouples users from our APT and YUM repos are actually hosted, allowing us to change the hosting mechanism without breaking users' URLs.

> Historic note: our APT and YUM repos used to be hosted on Bintray. But Bintray shut down on March 1 2021. The HTTP redirection mechanism allowed us to move away from Bintray with minimal downtime, and without breaking users' repository URLs.

Each Nginx instance is a Kubernetes Deployment with replicas=1. They are identically configured. They serve these virtual hosts:

 - `apt.fullstaqruby.org` — redirects everything to the APT repo bucket.
 - `yum.fullstaqruby.org` — redirects everything to the YUM repo bucket.

There is a primary instance and a secondary instance. The primary is scheduled on a normal node pool, while the secondary is scheduled on a preemtible node pool (and thus can go down at any time). Having two instances scheduled on different nodes allows high availability. But we honestly don't expect that much to go wrong, so the secondary's node pool is made preemptible in order to save costs.

All the Nginx pods, from both Deployments, are grouped together via a Kubernetes Services. Since each virtual host listens on a different port, we have two Kubernetes Ingresses — one for each subdomain — that each forwards to a different port in the Service. This allows the Ingresses to load balance traffic between the primary and the secondary.

TLS is configured through the Ingresses, using [Google-managed TLS certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs).

## Kubernetes cluster

 * Administered by role: Infra Maintainers

The Kubernetes cluster runs our Nginx web servers. We have two node pools: one based on normal GCE instances, and one based on preemptible instances. Kubernetes workloads are distributed over these two node pools. The reason why we have a preemptible node pool, is to save costs.

## Domain name

 * Administrated by role: Infra Owners

The `fullstaqruby.org` domain is registered at [TransIP](https://www.transip.nl/). It's registered using [Fullstaq](https://www.fullstaq.com)'s account. The DNS zone is not managed at TransIP, but at Google Cloud DNS.

## Bintray

 * Account is administered by role: Infra Owners
 * Repositories are administered by role: Infra Maintainers

All packages are stored on Bintray's Fullstaq account. This is an open source account. There, we have two repositories defined: one for APT, one for YUM.

The account itself is administered by the Infra Owners role, but the repositories inside are administered by the Infra Maintainers role.

Note that the Infrastructure team does not maintain the packages _inside_ the repositories; that's left to package maintainers.

Package maintainers' CI/CD systems make use of Fabian Met's API key, in order to access repositories. A copy of this key is stored in the `fullstaq-ruby-hisec` Google Cloud project's Secret Manager.

The Bintray account also stores a copy of the GPG private key, which is used to sign the repositories. This key cannot be read back from Bintray.

## GPG private key

 * Administered by role: Infra Owners

The GPG private key is used to sign APT and YUM repositories. We store the canonical copy in Secrets Manager in the `fullstaq-ruby-hisec` Google Cloud project. We also store a secondary copy in Bintray, to allow it to sign repositories.

## Google Cloud service account for CI/CD

 * Administered by role: Infra Maintainers

The `fullstaq-ruby` Google Cloud project has a service account, which has full access to the container registry. It's used by the Server Edition's CI/CD system.

## Github CI bot account

 * Administered by role: Infra Owners

This Github bot account is used by the Server Edition's CI/CD system. The account itself (and its email address) is administered by Infra Owners. It has a personal access token, which is installed as a secret in the Server Edition's repo, so that its CI/CD system can perform work under the bot account.
