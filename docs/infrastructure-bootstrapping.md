# Infrastructure bootstrapping

We try to codify infrastructure as much as possible using Terraform and Kubernetes YAML. However:

 * Not everything _can_ be automated. For example, we need to setup Google Cloud Storage buckets for storing Terraform state, before we can use Terraform.
 * Not everything _should_ be automated. For example, the `fullstaq-ruby-hisec` project contains such sensitive data, that giving access to CI/CD systems would pose a security risk.

This document describes how one can restore the entire infrastructure (including manual steps) in case of a disaster. It is to be performed by an [Infra Owner](roles.md).

## Step 1: Create Google Cloud projects

In Google Cloud, create two projects:

 * `fullstaq-ruby`
 * `fullstaq-ruby-hisec`

## Step 2: Generate & store GPG private key in Secret Manager

 1. Generate a GPG private key with these parameters:
     - Name: Fullstaq Ruby
     - Email: info@fullstaq.com
     - Algorithm: 4096-bit RSA (or stronger)
 2. Go to the `fullstaq-ruby-hisec` Google Cloud project.
 3. Go to Security ➜ Secret Manager.
 4. Create a secret with the name `gpg-private-key` and upload the private key.

## Step 3: Create Github repositories

Create the following Github repositories:

 * `fullstaq-labs/fullstaq-ruby-umbrella`
 * `fullstaq-labs/fullstaq-ruby-server-edition`
 * `fullstaq-labs/fullstaq-ruby-infra`
 * `fullstaq-labs/fullstaq-ruby-website`

## Step 4: Create Terraform state buckets

In the `fullstaq-ruby` Google Cloud project, create a Cloud Storage bucket with the following parameters:

 * Name: fullstaq-ruby-infra-terraform-state
 * Location type: Region
 * Location: europe-west4
 * Default storage class: Standard
 * Access control: Uniform
 * Encryption: Google-managed key
 * No public access
 * No retention policy
 * No labels

In the `fullstaq-ruby-hisec` Google Cloud project, create a Cloud Storage bucket with the following parameters:

 * Name: fullstaq-ruby-infra-hisec-terraform-state
 * Location type: Region
 * Location: europe-west4
 * Default storage class: Standard
 * Access control: Uniform
 * Encryption: Google-managed key
 * No public access
 * No retention policy
 * No labels

## Step 5: Run Terraform (hisec)

Setup the Google Cloud CLI's application default credentials if you haven't yet:

~~~bash
gcloud auth application-default login
~~~

Then run Terraform:

~~~bash
cd terraform-hisec
terraform init
terraform apply
~~~

## Step 6: Run Terraform (normal)

Setup the Google Cloud CLI's application default credentials if you haven't yet:

~~~bash
gcloud auth application-default login
~~~

Then run Terraform:

~~~bash
cd terraform
terraform init
terraform apply
~~~

## Step 7: Register domain

In [TransIP](https://www.transip.nl/), register the domain `fullstaqruby.org`.

Configure it to use the Google Cloud DNS zone in the `fullstaq-ruby` project. For instruction on how to do this, go to the Google Cloud DNS zone's configuration panel, and view the "Registrar setup" instructions.

## Step 8: Install service account private keys as Github Actions secrets

Terraform has created two service accounts. Their corresponding private keys must be installed as Github Actions secrets in the corresponding Github projects.

 - _Infrastructure CI Bot_: used by the Infrastructure team's CI/CD systems.

   Fetch the private key (in JSON format, base64-encoded) from the Terraform state and decode it:

   ~~~bash
   pushd terraform && terraform show -json | jq -r '.values.root_module.resources[] | select(.name == "infra-ci-bot-sa-key") | .values.private_key' | base64 --decode && popd
   ~~~

   In the [fullstaq-ruby-infra](https://github.com/fullstaq-labs/fullstaq-ruby-infra/settings/secrets) repo, paste this value into a secret named `GCLOUD_KEY`.

 - _Server Edition CI Bot_: used by Server Edition's developers' CI/CD systems to publish artifacts to the `fullstaq-ruby` Google Cloud project.

   Fetch the private key (in JSON format, base64-encoded) from the Terraform state:

   ~~~bash
   pushd terraform && terraform show -json | jq -r '.values.root_module.resources[] | select(.name == "server-edition-ci-bot-sa-key") | .values.private_key' && popd
   ~~~

   In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/secrets) repo, paste this value into a secret named `GCLOUD_KEY`.

## Step 9: Register a Github bot account

### Create an email inbox for the Github bot account

In the Fullstaq G Suite admin console, create a new group:

 * Name: Fullstaq Ruby CI bot
 * Email: fullstaq-ruby-ci-bot@fullstaq.com

Go to its [Advanced Settings](https://groups.google.com/a/fullstaq.com/g/fullstaq-ruby-ci-bot/settings) and ensure the following settings:

 * General:
    - Who can see this group: Organisation members
    - Who can join this group: Invited users only
    - Who can view conversations: Group managers
    - Who can post: Anyone on the web
    - Who can view members: Group managers
 * Member privacy:
    - Identification required for new members: Display profile name only
    - Who can view the member's email addresses: Group managers
 * Posting policies:
    - Conversation history: on
    - Who can moderate content: Group managers
    - Who can moderate metadata: Group managers
    - Who can post as the group: Group owners
    - Message moderation: No moderation
    - New member restrictions: No posting restriction for new members
 * Member moderation
    - Who can manage members: Group managers
    - Permission to modify custom roles: Group owners

### Register the Github bot account

Account details:

 * Username: fullstaq-ruby-ci-bot
 * Email: fullstaq-ruby-ci-bot@fullstaq.com

Store the password in Secret Manager:

 1. Go to the `fullstaq-ruby-hisec` Google Cloud project.
 2. Go to Security ➜ Secret Manager.
 3. Create a secret with the name `fullstaq-ruby-ci-bot-password` and insert the password.

### Personal access token

Create a personal access token:

 * Note: Server Edition CI
 * Scope: repo

Store this token in Secret Manager:

 1. Go to the `fullstaq-ruby-hisec` Google Cloud project.
 2. Go to Security ➜ Secret Manager.
 3. Create a secret with the name `fullstaq-ruby-ci-bot-server-edition-pat` and insert the personal access token.

### Install Github Actions secret

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/secrets) repo, create a Github Actions secret named `WORKFLOW_DISPATCH_TOKEN`. Set it to the personal access token.

### Grant access to key repositories

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/access) repo, add fullstaq-ruby-ci-bot as a collaborator. Grant the "Write" access.

## Step 10: Onboard everybody

Onboard everybody in the [members list](members.md) according to the [onboarding instructions](onboarding.md).
