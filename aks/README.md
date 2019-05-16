1. The Azure provider in this example uses the Azure storage account remote backend to store terraform state - you can use s3 buckets to do the same. This helps in a distributed team setup and also avoids storing sensitive data on the local filesystem in plaintext (cloud provider backends support encryption of data at rest). To use the Azure storage account backend create a blob container in an Azure storage account and create a backend config file with that information. The templates use partial configuration and expect a backend config file via the `-backend-config=PATH` option when running `terraform init`. To avoid putting the storage account key/shared access secret set the `ARM_ACCESS_KEY` or `ARM_SAS_TOKEN` env variable before running `terraform init`.

2. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
-  location
-  az_resource_group 
-  ssh_public_key (SSH key file to SSH into worker nodes)
-  agent_admin(SSH user name)
-  client_id (Azure Service Principal client id - must be created with `az ad sp create-for-rbac`, cannot be created via portal)  
-  client_secret ( Azure SP client secret)
- cluster_labels (any cluster labels, an optional map of key value pairs)
- project (for external-dns with GCP cloud DNS, GCP peoject id) 
- gcp_dns_sa_key (for external-dns with GCP, GCP service account key location) 

3. `terraform init -backend-config=<BE-config-file-location>`

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`

6. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set your KUBECONFIG env var to point to this file.

7. Check the default namespace to make sure `external-dns` and Ingress Controller are deployed.

8. Deploy UAA as usual via the helm chart.

8. If you are using loadbalanced services, once the services are up, run `ext-dns-uaa-svc-annotate.sh` to let `external-dns` generate the DNS entries for the `uaa-uaa-public` service. If you are using Ingress, you don't need to do anything.

9. Grab the CA_CERT from the secret and deploy SCF. 
  