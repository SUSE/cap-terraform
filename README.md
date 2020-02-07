# Provision public cloud k8s clusters with Terraform for CAP deployment

**Note: For a full "end-to-end" deployment of SUSE CAP, use the [e2e-cap-deploy branch](https://github.com/SUSE/cap-terraform/tree/e2e-cap-deploy).**

The goal is to setup a cluster and configure it such that all that's needed for CAP deployment is the `helm install`s. 
If you'd like to do an automated, end-to-end CAP deployment check the `e2e-cap-deployment` branch.
For details on how to use the templates for specific providers see the respective READMEs in the provider directories.

Few general notes:

- The terraform state is stored locally for all providers. The AKS instructions describe how to use a remote terraform backend with an Azure storage account. The same idea can be used for other providers. Using a remote backend is recommended to avoid storing sensitive information in plain text in Terraform state files (remote backend storage is encrypted).

- The GKE and AKS templates use `external-dns` (https://github.com/kubernetes-incubator/external-dns) for automatic setup of DNS records. Before you can use it you'll need to setup appropriate DNS zones with registered domain names in your cloud DNS provider of choice. The examples here use Azure DNS and GCP Cloud DNS and would require an Azure Service Principal or GCP Service Account with sufficient permissions to setup DNS records.

- `external-dns` can handle DNS records for both Ingress(es) as well as k8s LoadBalancer services. If you are using Ingress you don't need to take any additional steps as `exernal-dns` will scan Ingress objects for hostnames and will create appropriate DNS entries but if you are using LoadBalancer services you'll need to annotate those services to allow `external-dns` to set up DNS records. The two scripts, `ext-dns-<uaa/cf>-svc-annotate.sh` do just that. You'll need to run the scripts after the k8s services have been deployed from the UAA and SCF charts. 

- If you'd like, you can use `cert-manager` (https://github.com/jetstack/cert-manager) for automated setup of certificates. 
See the `e2e-cap-deploy` branch for examples of an end-to-end CAP deployment that uses LE to provision certificates for AKS and GKE. 

