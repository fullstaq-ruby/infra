# Deployment guide

This guide explains how to deploy the infrastructure, both initially as well as updates.

## Prerequisites

You need Terraform, kubectl and the Google Cloud CLI.

## Initial deployment

Create the `fullstaq-ruby` project in Google Cloud. And within that project, create a Google Cloud Storage bucket for storing the Terraform state.

Next, create a Google Cloud CLI configuration for Fullstaq Ruby, and make sure the Google Cloud CLI is properly logged in (both using normal auth and application default auth):

~~~bash
gcloud config configurations create fullstaq-ruby
gcloud auth login --update-adc
gcloud config set project fullstaq-ruby
~~~

Next, initialize Terraform:

~~~bash
cd terraform
terraform init
~~~

Finally, create the infrastructure:

~~~bash
terraform apply
~~~

Terraform would have created a Kubernetes cluster. Pass its connection credentials to kubectl:

~~~bash
gcloud container clusters get-credentials fullstaq-ruby-autopilot --configuration fullstaq-ruby --region us-east4
~~~

Set the default namespace:

~~~bash
kubectl config set-context --current --namespace=fullstaq-ruby
~~~

Then apply its Kustomization file:

~~~bash
kubectl apply --context=gke_fullstaq-ruby_us-east4_fullstaq-ruby-autopilot -k ../kubernetes
~~~

## Updates

These steps assume that your Google Cloud CLI is properly logged in and set to the right project, that your Terraform is initialized, and that your kubectl is authenticated to the Kubernetes cluster.

~~~bash
cd terraform
terraform apply
kubectl apply --context=gke_fullstaq-ruby_us-east4_fullstaq-ruby-autopilot -k ../kubernetes
~~~
