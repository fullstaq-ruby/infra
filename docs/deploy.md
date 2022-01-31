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

 4. Get the credentials for the Kubernetes cluster:

    ~~~bash
    gcloud container clusters get-credentials fullstaq-ruby-autopilot --configuration fullstaq-ruby --region us-east4
    ~~~

 5. Set the default namespace:

    ~~~bash
    kubectl config set-context --current --namespace=fullstaq-ruby
    ~~~

 6. Apply the Kustomization:

    ~~~bash
    kubectl apply --context=gke_fullstaq-ruby_us-east4_fullstaq-ruby-autopilot -k ../kubernetes
    ~~~
