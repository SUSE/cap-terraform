## Prerequisites

* Create a GCP service account with the following permissions, on the preferred target project:
    - Compute Admin (`compute.admin`)
    - Kubernetes Engine Admin (`container.admin`)
    - Service Account User (`iam.serviceAccountUser`)
  ```
  gcloud iam service-accounts create $(name)
  gcloud projects add-iam-policy-binding $(project) --member=user:$(name) --role=roles/compute.admin
  gcloud projects add-iam-policy-binding $(project) --member=user:$(name) --role=roles/container.admin
  gcloud projects add-iam-policy-binding $(project) --member=user:$(name) --role=roles/iam.serviceAccountUser
  gcloud iam service-accounts keys create ~/cap-credentials.json --iam-account $(name)@$(project).iam.gserviceaccount.com
  ```
* Create a 2nd GCP service account for DNS administration (or grant the 1st account additionally):
    - DNS Administrator (`dns.admin`)
  ```
  gcloud iam service-accounts create $(name)
  gcloud projects add-iam-policy-binding $(project) --member=user:$(name) --role=roles/dns.admin
  gcloud iam service-accounts keys create ~/cap-dns-credentials.json --iam-account $(name)@$(project).iam.gserviceaccount.com
  ```
  Be sure to store the credentials files security, as these can be used to authenticate as your service account. See https://cloud.google.com/iam/docs/granting-changing-revoking-access for more details on setting up GCP IAM accounts.
* Create a _Cloud DNS Zone_ in the target project, using a publicly resolvable subdomain:
  ```
  gcloud beta dns --project=$(project) managed-zones create --dns-name=$(subdomain)
  ```
  The DNS zone will host the cluster's DNS records in a specific domain name. See https://cloud.google.com/dns/docs/zones/ for details on setting up a _Cloud DNS Zone_.

## Setup

1. Create a `terraform.tfvars` or `terraform.tfvars.json` file with the following information:
    - `instance_count` - The number of worker nodes in your cluster. (Minimum: 3, Maximum 50)
    - `instance_type` - The type of instance used for the provisioned workers.
    - `project` - The GCP project to manage resources in.
    - `location` - The GCP region where the cluster is placed, including the zone.
    - `credentials_json` - Contents of a service account key file in JSON format, with rights to create the GKE cluster and associated resources.
    - `dns_credentials_json` - Contents of a service account key file in JSON format, with rights to edit DNS.
    - `admin_password` - Intial password for Cloud Foundry 'admin' user, UAA 'admin' OAuth client, and metrics 'admin' login. We recommend changing this password after deployment. See https://documentation.suse.com/suse-cap/single-html/cap-guides/#cha-cap-manage-passwords
    - `disk_size_gb` - The worker node storage capacity. (Minimum:80, Maximum: 65536)
    - `cluster_labels` - Tags to be applied to resources in your cluster. (Optional)
    - `cap_domain` - The FQDN of your cluster. Must be a subdomain of your Cloud DNS Zone.
    - `email` - Email address to send TLS certificate notifications to.

    **⚠ NOTE:** _This should be in your `.gitignore` or otherwise outside source control as it contains sensitive information._

2. `terraform init`

3. `terraform plan -out <PLAN-path>`

4. `terraform apply plan <PLAN-path>`

## Results

* A kubeconfig named `kubeconfig` is generated in the same directory TF is run from. Set your `KUBECONFIG` env var to point to this file. Please note that the credentials in this file are valid for only 1 hour. See https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl for details on how to maintain access via `kubectl`.

* The `helm install`s should have been triggered as part of step 4. Check the pods in uaa, scf, stratos and metrics namespace to make sure they all come up and are ready. URLs are included in the TF output for convenience.
