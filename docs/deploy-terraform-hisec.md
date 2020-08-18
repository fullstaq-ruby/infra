# Deploying terraform-hisec

> For a conceptual description of terraform-hisec, see: [Infrastructure as code]

Setup the Google Cloud CLI's application default credentials if you haven't yet:

~~~bash
gcloud auth application-default login
~~~

Then:

~~~bash
cd terraform-hisec
terraform init
terraform apply
~~~
