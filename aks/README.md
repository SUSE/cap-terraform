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
Note that the adClientId/Secret above are the same as the client_id/client_secret above for the Azure SP which should have sufficient rights to create DNS records in the resource group hosting the DNS zone.

2. `terraform init`

3. `terraform plan -out <PLAN-path>`

4. `terraform apply plan <PLAN-path>`

5. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set your KUBECONFIG env var to point to this file.
