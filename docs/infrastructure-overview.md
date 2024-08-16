## Infrastructure overview

The following diagram shows which infrastructure components exist and how they relate to each other. The bubbles on the corner of a component shows which [role](roles.md) administers that component.

![Infrastructure overview diagram](infrastructure-overview.drawio.svg)

## Google Cloud projects

- Administrated by role: Infra Owners

All Google Cloud resources are contained in two projects:

- `fullstaq-ruby` for normal resources. Infra Maintainers have full access to all resources _inside_ this project.
- `fullstaq-ruby-hisec` for especially sensitive resources. Only Infra Owners have access to the resources inside this project.

## Google Cloud service account for Server Edition CI/CD

- Administered by role: Infra Maintainers

The `fullstaq-ruby` Google Cloud project has a service account. It's used by the Server Edition's CI/CD system. This service account:

- Has full access to the Server Edition CI artifacts store.
- Has full access to the container registry, in order to access and store [build environment images](https://github.com/fullstaq-ruby/server-edition/blob/main/dev-handbook/build-environments.md).
- Has full access to the APT and YUM repo buckets, in order to publish new packages.

## Google Cloud service account for Infrastructure CI/CD

- Administered by role: Infra Maintainers

The `fullstaq-ruby` Google Cloud project has a service account. It's used by the Infrastructure repository's CI/CD system. This service account:

- Has full access to the container registry, in order to publish new API server images.
- Can deploy new versions of the API server.

## API server

- Administered by role: Infra Maintainers

The API server is a service that allows performing limited management operations on the infrastructure. It mainly exists to securely allow the Server Edition's CI to tell Nginx about the fact that new packages have been deployed. It's hosted on Google Cloud Run.

The API server's source code lives in the Infrastructure repository, and is deployed by that repository's CI/CD system.

The API server is not defined in Terraform, but is defined in the Infrastructure's CI/CD system in the form of a `gcloud` call.

## Nginx web server

- Administered by role: Infra Maintainers

We run one Nginx instance, which serves these virtual hosts:

- `apt.fullstaqruby.org` — redirects everything to the APT repo bucket.
- `yum.fullstaqruby.org` — redirects everything to the YUM repo bucket.

Nginx's only purpose is to redirect traffic. Users interact primarily with `{apt,yum}.fullstaqruby.org` instead of with the APT and YUM repo buckets directly. This decouples users from our APT and YUM repos are actually hosted, allowing us to change the hosting mechanism without breaking users' URLs.

> Historic note: our APT and YUM repos used to be hosted on Bintray. But Bintray shut down on March 1 2021. The HTTP redirection mechanism allowed us to move away from Bintray with minimal downtime, and without breaking users' repository URLs.

TLS is configured through the Ingress, using [Google-managed TLS certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs).

## Kubernetes cluster

- Administered by role: Infra Maintainers

The Kubernetes cluster runs our Nginx web server. This cluster is in Autopilot mode.

## DNS, static IPs, Ingresses

- Administered by role: Infra Maintainers

All DNS entries for `fullstaqruby.org` are managed through Google Cloud DNS, inside the `fullstaq-ruby` project.

- `fullstaqruby.org` points to Github Pages, where we host the [website](https://github.com/fullstaq-ruby/website).
- `{apt,yum}.fullstaqruby.org` point to Nginx's two virtual hosts, via two different static IPs and two different Kubernetes Ingresses.

## Domain name

- Administrated by role: Infra Owners

The `fullstaqruby.org` domain is registered at [TransIP](https://www.transip.nl/). It's registered using [Fullstaq](https://www.fullstaq.com)'s account. The DNS zone is not managed at TransIP, but at Google Cloud DNS.

## Github CI bot account

- Administered by role: Infra Owners

This Github bot account is used by the Server Edition's CI/CD system. The account itself (and its email address) is administered by Infra Owners. It has a personal access token, which is installed as a secret in the Server Edition's repo, so that its CI/CD system can perform work under the bot account.

## Terraform state (normal)

- Administered by role: Infra Maintainers

The Terraform state for normal infrastructure is stored in a Google Cloud Storage bucket, inside the `fullstaq-ruby` project.

## Terraform state (hisec)

- Administered by role: Infra Owners

The Terraform state for sensitive infrastructure is stored in a Google Cloud Storage bucket, inside the `fullstaq-ruby-hisec` project.

## Server Edition APT & YUM repo buckets

- Administered by role: Infra Maintainers

The Server Edition's APT and YUM repositories are stored inside these buckets. These buckets are publicly readable.

Users don't access these buckets directly. Instead, they access `apt.fullstaqruby.org` and `yum.fullstaqruby.org` (served by the Nginx web servers), which redirect to these buckets.

## Container registry

- Administered by role: Infra Maintainers

The `fullstaq-ruby` project has a container registry. This registry has two uses:

- It's used by developers' CI/CD systems, for example to store [build environment images](https://github.com/fullstaq-ruby/server-edition/blob/main/dev-handbook/build-environments.md).
- It's used to store the API server's images.

## Server Edition CI artifacts store

- Administered by role: Infra Maintainers

The Server Edition's CI/CD system stores artifacts in this bucket, for the purpose of implementing [resumption](https://github.com/fullstaq-ruby/server-edition/blob/main/dev-handbook/ci-cd-resumption.md). Objects in this bucket only live for 30 days.

## Server Edition CI cache store

- Administered by role: Infra Maintainers

The Server Edition's CI/CD system stores caches in this bucket. Objects are automatically deleted 90 days after last access.

## GPG private key

- Administered by role: Infra Owners, Infra Maintainers

The GPG private key is used to sign APT and YUM repositories. We store the canonical copy in Secrets Manager in the `fullstaq-ruby-hisec` Google Cloud project. We store a secondary copy in the Secret Manager in the `fullstaq-ruby` Google Cloud project.
