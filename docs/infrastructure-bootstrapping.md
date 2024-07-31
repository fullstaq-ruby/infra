# Infrastructure bootstrapping

We try to codify infrastructure as much as possible using Terraform and Kubernetes YAML. However:

- Not everything _can_ be automated. For example, we need to setup Azure Blob Storage for storing Terraform state, before we can use Terraform.
- Not everything _should_ be automated. For example, the `fullstaq-ruby-hisec` project contains such sensitive data, that giving access to CI/CD systems would pose a security risk.

This document describes how one can restore the entire infrastructure (including manual steps) in case of a disaster. It is to be performed by an [Infra Owner](roles.md).

## Step 1: Prerequisites

- Sign up for an Azure subscription and Entra ID tenant.
- Sign up for a Google Cloud account.
- Install and login to the Azure CLI and Google Cloud CLI.
- Set some shell variables:

  ```bash
  AZURE_SUBSCRIPTION_ID=...fill in...
  TF_RESOURCE_GROUP_NAME=fullstaq-ruby-terraform-hisec
  TF_RESOURCE_GROUP_LOCATION=westeurope
  TF_STORAGE_ACCOUNT_NAME=fsrubyterraformhisec
  ```

- Modify the default values in the following files to match the shell variables' values:

  - terraform-hisec/backend.tf
  - terraform-hisec/variables.tf
  - terraform/backend.tf (tenant_id and subscription_id only)
  - terraform/variables.tf
  - ansible/vars/azure.yml

## Step 2: Secure Entra ID

In Entra ID, go to "Manage" -> "User settings".

- Users can register applications: yes.
- Restrict non-admin users from creating tenants: yes.
- Users can create security groups: no.
- Guest user access restrictions: Guest user access is restricted to properties and memberships of their own directory objects (most restrictive).
- Restrict access to Microsoft Entra admin center: no.

In Entra ID, go to "Manage" -> "Enterprise applications" -> "Security" -> "Consent and permissions".

- Select "Do not allow user consent".

## Step 3: Setup Azure Blob Storage Terraform state bucket

Create the resource group, storage account and container:

```bash
MY_OBJECT_ID=$(az ad signed-in-user show --query id --output tsv)

az group create --subscription "$AZURE_SUBSCRIPTION_ID" --name "$TF_RESOURCE_GROUP_NAME" --location "$TF_RESOURCE_GROUP_LOCATION"

az storage account create --subscription "$AZURE_SUBSCRIPTION_ID" --resource-group "$TF_RESOURCE_GROUP_NAME" --name "$TF_STORAGE_ACCOUNT_NAME" --sku Standard_ZRS --allow-shared-key-access false --min-tls-version TLS1_2
az storage account update --subscription "$AZURE_SUBSCRIPTION_ID" --resource-group "$TF_RESOURCE_GROUP_NAME" --name "$TF_STORAGE_ACCOUNT_NAME" --set defaultToOAuthAuthentication=true
az storage container create --subscription "$AZURE_SUBSCRIPTION_ID" --account-name "$TF_STORAGE_ACCOUNT_NAME" --name tfstate --auth-mode login
az role assignment create --assignee "$MY_OBJECT_ID" --role "Storage Blob Data Owner" --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$TF_RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$TF_STORAGE_ACCOUNT_NAME"
```

## Step 4: Run initial Terraform (hisec)

```bash
cd terraform-hisec
terraform init
terraform apply
cd ..
```

## Step 5: Generate & store GPG private key in Key Vault

1.  Generate a GPG private key with these parameters:

    - Name: Fullstaq Ruby
    - Email: maintainers@fullstaqruby.org
    - Algorithm: 4096-bit RSA (or stronger)

2.  Store this in the Azure Key Vault for Infra Owners:

    Export the private key to a file "fullstaq-ruby-priv.asc" (ASCII armor). Then:

    ```bash
    az keyvault secret set --vault-name fsruby2infraowners --name server-edition-gpg-private-key -f fullstaq-ruby-priv.asc
    rm fullstaq-ruby-priv.asc
    ```

## Step 6: Create Github repositories

Create the following Github repositories:

- `fullstaq-ruby/umbrella`
- `fullstaq-ruby/server-edition`
- `fullstaq-ruby/infra`
- `fullstaq-ruby/website`

## Step 7: Spin up a VPS

1. Spin up an Ubuntu >= 24.04 VPS somewhere, for example at Hetzner.
2. Setup its reverse DNS as `backend.fullstaqruby.org`.
3. Fill in its IP address in `terraform/variables.tf` -> `backend_server_ipv*`.

## Step 8: Run initial Terraform (normal)

Run Terraform:

```bash
cd terraform
terraform init
terraform apply
cd ..
```

## Step 9: Register domain

Register the domain `fullstaqruby.org`. Configure it to use the Azure DNS zone.

## Step 10: Run initial Ansible

Make sure the Azure CLI is logged in, then:

```bash
cd ansible
ansible-playbook -i hosts.ini -v main.yml
cd ..
```

## Step 11: Populate Github Actions secrets

Terraform has created two Google Cloud service accounts and one Azure storage account. Their corresponding private keys and connection string must be installed as Github Actions secrets in the corresponding Github projects.

- _Infrastructure CI Bot_: used by the Infrastructure team's CI/CD systems.

  Fetch the private key (in JSON format, base64-encoded) from the Terraform state and decode it:

  ```bash
  pushd terraform && terraform show -json | jq -r '.values.root_module.resources[] | select(.name == "infra-ci-bot-sa-key") | .values.private_key' | base64 --decode && popd
  ```

  In the [fullstaq-ruby/infra](https://github.com/fullstaq-ruby/infra/settings/secrets) repo, paste this value into a secret named `GCLOUD_KEY`.

- _Server Edition CI Bot_: used by Server Edition's developers' CI/CD systems to publish artifacts to the `fullstaq-ruby` Google Cloud project, and to cache to the `fsruby2seredci1` Azure storage account.

  - Fetch the Google Cloud service account private key (in JSON format, base64-encoded) from the Terraform state:

    ```bash
    pushd terraform && terraform show -json | jq -r '.values.root_module.resources[] | select(.name == "server-edition-ci-bot-sa-key") | .values.private_key' && popd
    ```

    In the [fullstaq-ruby/server-edition](https://github.com/fullstaq-ruby/server-edition/settings/secrets) repo, paste this value into a secret named `GCLOUD_KEY`.

  - Fetch the Azure storage account connection string from the Terraform state:

    ```bash
    pushd terraform && terraform show -json | jq -r '.values.root_module.resources[] | select(.address == "azurerm_storage_account.server-edition-ci") | .values.primary_blob_connection_string' && popd
    ```

    In the [fullstaq-ruby/server-edition](https://github.com/fullstaq-ruby/server-edition/settings/secrets) repo, paste this value into a secret named `AZURE_CI1_STORAGE_CONNECTION_STRING`.

## Step 12: Register a Github bot account

### Create an email inbox for the Github bot account

In the Fullstaq G Suite admin console, create a new group:

- Name: Fullstaq Ruby CI bot
- Email: fullstaq-ruby-ci-bot@fullstaq.com

Go to its [Advanced Settings](https://groups.google.com/a/fullstaq.com/g/fullstaq-ruby-ci-bot/settings) and ensure the following settings:

- General:
  - Who can see this group: Organisation members
  - Who can join this group: Invited users only
  - Who can view conversations: Group managers
  - Who can post: Anyone on the web
  - Who can view members: Group managers
- Member privacy:
  - Identification required for new members: Display profile name only
  - Who can view the member's email addresses: Group managers
- Posting policies:
  - Conversation history: on
  - Who can moderate content: Group managers
  - Who can moderate metadata: Group managers
  - Who can post as the group: Group owners
  - Message moderation: No moderation
  - New member restrictions: No posting restriction for new members
- Member moderation
  - Who can manage members: Group managers
  - Permission to modify custom roles: Group owners

### Register the Github bot account

Account details:

- Username: fullstaq-ruby-ci-bot
- Email: fullstaq-ruby-ci-bot@fullstaq.com

Store the password in Secret Manager:

1.  Go to the `fullstaq-ruby-hisec` Google Cloud project.
2.  Go to Security ➜ Secret Manager.
3.  Create a secret with the name `fullstaq-ruby-ci-bot-password` and insert the password.

### Personal access token

Create a personal access token:

- Note: Server Edition CI
- Scope: repo

Store this token in Secret Manager:

1.  Go to the `fullstaq-ruby-hisec` Google Cloud project.
2.  Go to Security ➜ Secret Manager.
3.  Create a secret with the name `fullstaq-ruby-ci-bot-server-edition-pat` and insert the personal access token.

### Install Github Actions secret

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/secrets) repo, create a Github Actions secret named `WORKFLOW_DISPATCH_TOKEN`. Set it to the personal access token.

### Grant access to key repositories

In the [fullstaq-ruby-server-edition](https://github.com/fullstaq-labs/fullstaq-ruby-server-edition/settings/access) repo, add fullstaq-ruby-ci-bot as a collaborator. Grant the "Write" access.

## Step 13: Onboard everybody

Onboard everybody in the [members list](members.md) according to the [onboarding instructions](onboarding.md).
