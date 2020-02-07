0. Prerequisites
  * Create an Azure Service Principal
    ```
    az ad sp create-for-rbac
    ```
    Note the SP must have sufficient privileges, the created account must have at least Contributor and DNS Zone Contributor roles. The data provided as output from this function will be required in the terraform variables.

  * Create a Resource Group
    ```
    az group create --name $(az_resource_group) --location $(location)
    ```
    This resource group will contain all resources of, and in support of your SUSE CAP cluster. Make note of the _name_ and _location_ which must be supplied in terraform variables.

  * Create a DNS zone
    ```
    az network dns zone create -g $(az_resource_group) -n $(dns_zone_name)
    ```
    The DNS zone will host the cluster's DNS records in a specific domain name. Make note of the _name_ which must be supplied in terraform variables. See https://docs.microsoft.com/en-us/azure/dns/ for details on setting up a DNS zone.

1. Create a `terraform.tfvars` or update the `terraform.tfvars.json` (should be in your `.gitignore` or outside source control as it contains sensitive information) file with the following information
  - `location` (Azure region - eastus, westus etc.)
  - `az_resource_group` (the resource group must exist), it the resource group which will be assigned to the created workers nodes
  - `ssh_public_key` (SSH public key for access to worker nodes)
  - `agent_admin` (SSH user name)
  - `subscription_id` (Your Azure subscription)
  - `client_id` (Azure Service Principal app id, from Azure SP data)  
  - `client_secret` (Azure SP "password", from Azure SP data)
  - `tenant_id` (Azure SP "tenantId", from Azure SP data)
  - `cluster_labels` (any cluster labels, an optional map of key value pairs)
  - `chart_values_file` (absolute filesystem location of the helm chart values yaml for deploying UAA, SCF, stratos and Metrics)
  - `stratos_metrics_config_file` (absolute filesystem location of the helm chart values yaml for deploying Metrics)
  - `disk_size_gb` ("100" this is the worker node storage capacity.)
  - `k8s_version` ("1.14.8" this is the K8s version, please always note that the used version must be higher than 1.10 and must be supported by the selected region)
  - `node_count` ("2" this is the number of worker nodes)
  - `machine_type` ("Standard_D4s_v3"  this is the node type used for the provisioned k8s workers/minion)
  - `cap_domain` ("xxxxxxx" this is the domain variable that will be used in the scf-config-values.yaml)
  - `email` (email address to send TLS certificate notifications to)
  - `dns_zone_name` (name of the Azure DNS Zone created for the cluster)

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

3. `terraform init`

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`

6. A kubeconfig named `aksk8scfg` is generated in the same directory TF is run from. Set your `KUBECONFIG` env var to point to this file.

7. The `helm install`s should have been triggered as part of step 5. Check the pods in uaa, scf, stratos and metrics namespace to make sure they all come up and are ready.
