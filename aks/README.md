1. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
-  location
-  az_resource_group 
-  ssh_public_key (SSH key file to SSH into worker nodes)
-  agent_admin(SSH user name)
-  client_id (Azure Service Principal client id - must be created with `az ad sp create-for-rbac`, cannot be created via portal)  
-  client_secret ( Azure SP client secret)
- cluster_labels (any cluster labels, an optional map of key value pairs)
- scf_domain (your domain where CAP will be deployed)
- azure_dns_json set this to the filesystem location of  a file azure-dns.json that contains the following info:
  {
    "tenantId": "xxxxxxxxxx",
    "subscriptionId": "xxxxxxx",
    "resourceGroup": "xxxxxx",
    "aadClientId": "xxxxx",
    "aadClientSecret": "xxxxx"
}
Note that you'll need an Azure SP (aadClientId/Secret above) which has sufficient rights to create DNS records in the resource group hosting the DNS zone.

2. `terraform init`

3. `terraform plan -out <PLAN-path>`

4. `terraform apply plan <PLAN-path>`

5. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set your KUBECONFIG env var to point to this file.

6. Check the default namespace to make sure `external-dns` and Ingress Controller are deployed.

7. Deploy UAA as usual via the helm chart.

8. If you are using loadbalanced services, once the services are up, run `ext-dns-uaa-svc-annotate.sh` to let `external-dns` generate the DNS entries for the `uaa-uaa-public` service. If you are using Ingress, you don't need to do anything.

9. Grab the CA_CERT from the secret and deploy SCF. 
  