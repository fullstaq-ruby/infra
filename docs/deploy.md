# Deployment guide

This guide explains how to deploy infrastructure updates. This guide is not for deploying the infrastructure from scratch! For that, see [Infrastructure bootstrapping](infrastructure-bootstrapping.md).

## Before you begin

 1. Install the [required development tools](required-devtools.md).

 2. Create a Google Cloud CLI configuration for Fullstaq Ruby, and make sure the Google Cloud CLI is properly logged in (both using normal auth and application default auth):

    ~~~bash
    gcloud config configurations create fullstaq-ruby
    gcloud auth login --update-adc
    gcloud config set project fullstaq-ruby
    ~~~

 3. Login the Azure CLI:

    ~~~bash
    az login
    ~~~

## Deploying updates

 1. Make sure the `fullstaq-ruby` Google Cloud CLI configuration is activated, and that the Azure CLI is logged in.

 2. Deploy `terraform-hisec/`:

     1. (Re)initialize Terraform if necessary:

        ~~~bash
        cd terraform-hisec
        terraform init
        ~~~

     2. Apply Terraform:

        ~~~bash
        terraform apply
        cd ..
        ~~~

 3. Deploy `terraform/`:

     1. (Re)initialize Terraform if necessary:

        ~~~bash
        cd terraform
        terraform init
        ~~~

     2. Apply Terraform:

        ~~~bash
        terraform apply
        cd ..
        ~~~

 4. Apply Ansible to the backend VM:

    ~~~bash
    cd ansible
    ansible-playbook -i hosts.ini -v main.yml
    cd ..
    ~~~

> The API server itself is not deployed by this playbook. Code changes under `apiserver/` are released by the `.github/workflows/apiserver.yml` workflow, which packages a tarball, attaches it to a GitHub Release, and triggers `POST /admin/upgrade_apiserver` on the live host.
