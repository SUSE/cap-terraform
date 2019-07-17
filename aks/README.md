0. Set the following env variables:

`export ARM_CLIENT_ID=<Azure SP Client ID>
 export ARM_CLIENT_SECRET=<Azure SP Client Secret>
 export ARM_TENANT_ID=<Tenant Id>
 export ARM_SUBSCRIPTION_ID=<Subscription id>
 `
 Once these vars are set they will allow the Azure SP to login to Azure before any Azure resources are provisioned. Note the SP must have sufficient privileges to deploy resources in the subscription.


1. Create a terraform.tfvars (should be in your .gitignore or outside source control as it contains sensitive information) file with the following information
    -  location (Azure region - eastus, westus etc.)
    -  az_resource_group 
    -  ssh_public_key (SSH key file to SSH into worker nodes)
    -  agent_admin(SSH user name)
    -  client_id (Azure Service Principal client id, same as in step 0 - must be created with `az ad sp create-for-rbac`, cannot be created via portal)  
    -  client_secret ( Azure SP client secret)
    - cluster_labels (any cluster labels, an optional map of key value pairs)
    - scf_domain (your domain where CAP will be deployed)
    - azure_dns_json - this is used by external-dns - set this to the filesystem location of  a file azure-dns.json that contains the following info:
    {
        "tenantId": "xxxxxxxxxx",
        "subscriptionId": "xxxxxxx",
        "resourceGroup": "xxxxxx",
        "aadClientId": "xxxxx",
        "aadClientSecret": "xxxxx"
    }
    - chart_values_yaml - filesystem location of the helm chart values yaml for deploying UAA and SCF.

Note that external-dns needs its own config setup and cannot reuse the values already set for tenant/subscription/resourcegroup etc. Also note the adClientId/Secret in this file do not have to be the same as the client_id/client_secret in step 1 above as long as this SP has sufficient rights to create DNS records in the resource group hosting the DNS zone.

2. In the helm chart values yaml use the following values to allow cert-manager to generate certificates for the ingress endpoints:

`ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 1024m
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    certmanager.k8s.io/acme-challenge-type: dns01
    certmanager.k8s.io/acme-dns01-provider: azuredns
`

If you change the values of the annotations above you'll need to make corresponding changes in the cert-manager setup (see the `cert-manager.tf` template and the associated scripts)
Set the value of the `UAA_CA_CERT` key to the PEM encoded value of the DST Root CA X3 cert, e.g.,

`UAA_CA_CERT: |
    -----BEGIN CERTIFICATE-----
    .....
    -----END CERTIFICATE-----
`

3. `terraform init`

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`

6. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set your KUBECONFIG env var to point to this file.

7. The `helm install`s should have been triggered as part of step 5. Check the pods in UAA and SCF namespace to make sure they all come up and are ready. 
