0. For configuring the Terraform AzureRM provider set up the following env variables:

```
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```
You'll need an Azure service principal that has adequate permissions to set up an AKS cluster - this SP must be created with `az ad sp create-for-rbac` and cannot be created via portal.

1. The Azure provider in this example can use the Azure storage account remote backend to store terraform state (it's currently commented out) - you can use s3 buckets to do the same. This helps in a distributed team setup and also avoids storing sensitive data on the local filesystem in plaintext (cloud provider backends support encryption of data at rest). To use the Azure storage account backend create a blob container in an Azure storage account and create a backend config file with that information. The templates use partial configuration and expect a backend config file via the `-backend-config=PATH` option when running `terraform init`. Alternatively, to avoid putting the storage account key/shared access secret in a backend config file set the `ARM_ACCESS_KEY` or `ARM_SAS_TOKEN` env variable before running `terraform init`.

2. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
-  `location`
-  `az_resource_group` (the resource group where the cluster will be deployed, must exist beforehand)
-  `ssh_public_key` (SSH key file to SSH into worker nodes)
-  `agent_admin`(SSH user name)
-  `client_id` (Azure Service Principal client id -  can alternatively set `TF_VAR_client_id` env var)  
-  `client_secret` ( Azure SP client secret,can alternatively set `TF_VAR_client_secret` env var)
- `cluster_labels` (any cluster labels, an optional map of key value pairs)
- `azure_dns_json` - file where the azure SP credentials are stored for creating Azure DNS entries. This SP can be the same as the one previously set up to create cluster etc. but does not have to be, i.e., this SP can be given just the rights for adding DNS records in an existing Azure DNS zone. The json file must be of the form below:

{
    "tenantId": "REDACTED",
    "subscriptionId": "REDACTED",
    "resourceGroup": "resource group where azure DNS zone is",
    "aadClientId": "REDACTED",
    "aadClientSecret": "REDACTED"
}

3. `terraform init`  (if you're using an Azure storage account backend you'll need to pass in `-backend-config=<BE-config-file-location>` or set the `ARM_ACCESS_KEY` env var to point to the storage account access key/shared access signature, see the Terraform Azure backend documentation for details)

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`

6. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set your KUBECONFIG env var to point to this file.

7. Check the default namespace to make sure `external-dns` and Ingress Controller are deployed.

8. Deploy UAA as usual via the helm chart.

9. If you are using loadbalanced services, once the services are up, run `ext-dns-uaa-svc-annotate.sh` to let `external-dns` generate the DNS entries for the `uaa-uaa-public` service. If you are using Ingress, you don't need to do anything.

10. Grab the CA_CERT from the secret and deploy SCF. 
  