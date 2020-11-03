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

## Step 3: Create Github repositories and CI account

Create the following Github repositories:

 * `fullstaq-labs/fullstaq-ruby-umbrella`
 * `fullstaq-labs/fullstaq-ruby-server-edition`
 * `fullstaq-labs/fullstaq-ruby-infra`
 * `fullstaq-labs/fullstaq-ruby-website`

## Step 4: Create a Bintray account

Sign up for an open source Bintray account, with organization name `fullstaq`.

### Organization settings

General:

 * Name: Fullstaq
 * Location: Netherlands
 * Website: https://fullstaq.com
 * Email: info@fullstaq.com
 * Show my email address to other users

GPG signing:

 * Upload the GPG public and private keys.

Accounts:

 * Twitter: fullstaq

### fullstaq-ruby-apt

Create a repo with this name.

 * Public access
 * Type: Debian
 * No trivial index
 * Default licenses: BSD 2-Clause, MIT

After creating, edit the repo, and set:

 * Sign using: User's/Organization's GPG private key
 * Content: Only meta-data files

In the repo, create a package.

 * Name: fullstaq-ruby
 * Maturity: Stable
 * Website: https://fullstaqruby.org
 * Issue tracker: https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/issues
 * Version control: https://github.com/fullstaq-labs/fullstaq-ruby-server-edition
 * Make download numbers in stats public

### fullstaq-ruby-yum

Create a repo with this name.

 * Public access
 * Type: RPM
 * YUM metadata folder depth: 2
 * YUM groups file: none, leave empty
 * Default licenses: BSD 2-Clause, MIT

After creating, edit the repo, and set:

 * Sign using: User's/Organization's GPG private key
 * Content: Only meta-data files

In the repo, create a package.

 * Name: fullstaq-ruby
 * Maturity: Stable
 * Website: https://fullstaqruby.org
 * Issue tracker: https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/issues
 * Version control: https://github.com/fullstaq-labs/fullstaq-ruby-server-edition
 * Make download numbers in stats public

## Step 5: Store Bintray API key in Secret Manager

 1. In Bintray, have the account owner create an API key.
 2. Go to the `fullstaq-ruby-hisec` Google Cloud project.
 3. Go to Security ➜ Secret Manager.
 4. Create two secrets:

     - `bintray-api-username`: the API key owner's Bintray username.
     - `bintray-api-key`: the API key.

## Step 6: Install Bintray API key as a Github Actions secret

In Bintray, have the account owner create an API key, if not already done.

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/secrets) repo, create the following Github Actions secrets:

 * `BINTRAY_API_USERNAME`: the Bintray account owner's username.
 * `BINTRAY_API_KEY`: the created API key.

## Step 7: Create Terraform state buckets

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

## Step 8: Run Terraform (hisec)

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

## Step 9: Run Terraform (normal)

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

## Step 10: Register domain

In [TransIP](https://www.transip.nl/), register the domain `fullstaqruby.org`.

Configure it to use the Google Cloud DNS zone in the `fullstaq-ruby` project. For instruction on how to do this, go to the Google Cloud DNS zone's configuration panel, and view the "Registrar setup" instructions.

## Step 11: Install service account private key as a Github Actions secret

Terraform has created a service account that developers' CI/CD systems can use to publish artifacts to the `fullstaq-ruby` Google Cloud project. We copy this service account's private key into a Github Actions secret.

First, fetch the private key (which is in JSON format, base64-encoded) from the Terraform state:

~~~bash
cd terraform
terraform show -json | jq -r '.values.root_module.resources[] | select(.name == "github-actions-sa-key") | .values.private_key'
~~~

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/secrets) repo, paste this value into a secret named `GCLOUD_KEY`.

## Step 12: Register a Github bot account

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
 3. Create a secret with the name `fullstaq-ruby-ci-bot-server-edition-ci-pat` and insert the personal access token.

### Install Github Actions secret

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/secrets) repo, create a Github Actions secret named `WORKFLOW_DISPATCH_TOKEN`. Set it to the personal access token.

### Grant access to key repositories

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/access) repo, add fullstaq-ruby-ci-bot as a collaborator. Grant the "Write" access.

## Step 13: Onboard everybody

Onboard everybody in the [members list](members.md) according to the [onboarding instructions](onboarding.md).
