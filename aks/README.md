0. Set the following env variables:

```
 export ARM_CLIENT_ID=<Azure SP Client ID>
 export ARM_CLIENT_SECRET=<Azure SP Client Secret>
 export ARM_TENANT_ID=<Tenant Id>
 export ARM_SUBSCRIPTION_ID=<Subscription id>
 ```
 These env vars are used by the Terraform AzureRM provider to login to Azure with the configured SP credentials.
 Note the SP must have sufficient privileges, the created account must have at least contributor role on the tenant you may used az cli by running  `az ad sp create-for-rbac`or via the portal by creating app
 registration account as assigning the specific role.


1. Create a `terraform.tfvars` or update the `terraform.tfvars.json` (should be in your `.gitignore` or outside source control as it contains sensitive information) file with the following information
    -  `location` (Azure region - eastus, westus etc.)
    -  `az_resource_group` (the resource group must exist), it the resource group which will be assigned to the created workers nodes
    -  `ssh_public_key` (SSH public key for access to worker nodes)
    -  `agent_admin`(SSH user name)
    -  `client_id` (Azure Service Principal app id, same as in step 0)  
    -  `client_secret` ( Azure SP password, same as in step 0)
    (alternatively, you can set the `TF_VAR_client_id` and `TF_VAR_client_secret` env vars)
    - `cluster_labels` (any cluster labels, an optional map of key value pairs)
    - `azure_dns_json` - this is used by external-dns - set this to the absolute filesystem location of  a file azure-dns.json that contains the following info, you can use the provided azure_dns_json.json:
    ```
    {
        "tenantId": "xxxxxxxxxx",
        "subscriptionId": "xxxxxxx",
        "resourceGroup": "xxxxxx",
        "aadClientId": "xxxxx",
        "aadClientSecret": "xxxxx"
    }
    ```
	Note that `external-dns` needs its own config setup and cannot reuse the values already set for tenant/subscription etc. *Also note the `resourceGroup` here is the resource group where the Azure DNS zone(s) are hosted, it's not the resource group where the cluster will be deployed*. The `aadClientId/Secret` in this file do not have to be the same as the client_id/client_secret in step 1 above as long as this SP has sufficient rights to create DNS records in the resource group hosting the DNS zone.

    - `chart_values_file` - absolute filesystem location of the helm chart values yaml for deploying UAA, SCF, stratos and Metrics.
    - `stratos_metrics_config_file` - absolute filesystem location of the helm chart values yaml for deploying Metrics.
	- `disk_size_gb`: "100" this is the worker node storage capacity.
	- `k8s_version`: "1.14.8" this is the K8s version, please always note that the used version must be higher than 1.10 and must be supported by the selected region.
    - `node_count`: "2" this is the number of worker nodes.
    - `machine_type`: "Standard_D4s_v3"  this is the node type used for the provisioned k8s workers/minion.
    - `cap_domain`: "xxxxxxx" this is the domain variable that will be used in the scf-config-values.yaml.


2. In the helm chart values yaml use the following values to allow `cert-manager` to generate certificates for the ingress endpoints, you may use the scf-config-values.yaml as a reference:

```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 1024m
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    certmanager.k8s.io/acme-challenge-type: dns01
    certmanager.k8s.io/acme-dns01-provider: azuredns
```

If you change the values of the annotations above you'll need to make corresponding changes in the cert-manager setup (see the `cert-manager.tf` template and the associated scripts)

3. Make appropriate substituions in the `le-prod-cert-issuer.yaml.template` and rename it to `le-prod-cert-issuer.yaml`.

4. `terraform init`

5. `terraform plan -out <PLAN-path>`

6. `terraform apply plan <PLAN-path>`

7. A kubeconfig named `aksk8scfg` is generated in the same directory TF is run from. Set your `KUBECONFIG` env var to point to this file.

8. The `helm install`s should have been triggered as part of step 5. Check the pods in uaa, scf, stratos and metrics namespace to make sure they all come up and are ready.
