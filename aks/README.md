1. The Azure provider in this example can use the Azure storage account remote backend to store terraform state (it's currently commented out) - you can use s3 buckets to do the same. This helps in a distributed team setup and also avoids storing sensitive data on the local filesystem in plaintext (cloud provider backends support encryption of data at rest). To use the Azure storage account backend create a blob container in an Azure storage account and create a backend config file with that information. The templates use partial configuration and expect a backend config file via the `-backend-config=PATH` option when running `terraform init`. To avoid putting the storage account key/shared access secret set the `ARM_ACCESS_KEY` or `ARM_SAS_TOKEN` env variable before running `terraform init`.

2. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
-  location
-  az_resource_group 
-  ssh_public_key (SSH key file to SSH into worker nodes)
-  agent_admin(SSH user name)
-  client_id (Azure Service Principal client id - must be created with `az ad sp create-for-rbac`, cannot be created via portal)  
-  client_secret ( Azure SP client secret)
- cluster_labels (any cluster labels, an optional map of key value pairs)
- azure_dns_json - file where the azure SP credentials are stored for creating Azure DNS entries. Must be of the form below:

{
    "tenantId": "REDACTED",
    "subscriptionId": "REDACTED",
    "resourceGroup": "resource group where azure DNS zone is",
    "aadClientId": "REDACTED",
    "aadClientSecret": "REDACTED"
}

3. `terraform init -backend-config=<BE-config-file-location>` (if you're using a backend, otherwise just `terraform init`)

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`

6. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set your KUBECONFIG env var to point to this file.

7. Check the default namespace to make sure `external-dns` and Ingress Controller are deployed.

8. Deploy UAA as usual via the helm chart.

8. If you are using loadbalanced services, once the services are up, run `ext-dns-uaa-svc-annotate.sh` to let `external-dns` generate the DNS entries for the `uaa-uaa-public` service. If you are using Ingress, you don't need to do anything.

9. Grab the CA_CERT from the secret and deploy SCF. 
  