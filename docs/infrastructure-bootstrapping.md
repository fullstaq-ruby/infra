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

## Step 11: Populate Github Actions secrets and variables

In the [fullstaq-ruby/server-edition](https://github.com/fullstaq-ruby/server-edition/settings/secrets) repo, create the following environments:

- test
- deploy

Create these environment-specific secrets:

- `AZURE_CI2_STORAGE_CONNECTION_STRING` ('test' environment):

  Fetch the value from the Terraform state:

  ```bash
  pushd terraform >/dev/null && terraform show -json | jq -r '.values.root_module.resources[] | select(.address == "azurerm_storage_account.server-edition-ci") | .values.primary_blob_connection_string'; popd >/dev/null
  ```

Create these repository variables:

- `AZURE_SUBSCRIPTION_ID`: see corresponding variable in terraform/variables.tf
- `AZURE_TENANT_ID`: see corresponding variable in terraform/variables.tf
- `GCLOUD_PROJECT_ID`: see corresponding variable in terraform/variables.tf
- `GCLOUD_PROJECT_NUM`: lookup the project number in Google Cloud.
- `CI_ARTIFACTS_BUCKET`: fetch using `pushd terraform >/dev/null && terraform show -json | jq -r '.values.root_module.resources[] | select(.address == "google_storage_bucket.server-edition-ci-artifacts") | .values.name'; popd >/dev/null`

Create these environment-specific variables:

- `AZURE_CLIENT_ID` ('test' environment): fetch using `pushd terraform-hisec >/dev/null && terraform show -json | jq -r '.values.root_module.resources[] | select(.address == "azuread_application.server-edition-github-ci-test") | .values.application_id'; popd >/dev/null`
- `AZURE_CLIENT_ID` ('deploy' environment): fetch using `pushd terraform-hisec >/dev/null && terraform show -json | jq -r '.values.root_module.resources[] | select(.address == "azuread_application.server-edition-github-ci-deploy") | .values.application_id'; popd >/dev/null`

## Step 13: Onboard everybody

Onboard everybody in the [members list](members.md) according to the [onboarding instructions](onboarding.md).
