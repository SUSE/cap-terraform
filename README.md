# Provision public cloud k8s clusters with Terraform for CAP deployment

The goal is to setup a cluster and configure it such that all that's needed for CAP deployment is the helm installs. For details on how to use the templates for specific providers see the respective READMEs in the provider directories.

Few general notes:

- The terraform state is stored locally for all providers. The AKS instructions describe how to use a remote terraform backend with an Azure storage account. The same idea can be used for other providers.

- The GKE and AKS templates use external-dns (https://github.com/kubernetes-incubator/external-dns) for automatic setup of DNS A records. Before you can use it you'll need to setup appropriate DNS zones in your cloud DNS provider of choice - the examples here use Azure DNS and GCP Cloud DNS and would require an Azure Service Principal or GCP service account with sufficient permissions to setup DNS records.

- external-dns can handle DNS records for both Ingress(es) as well as k8s LoadBalancer services. If you are using Ingress you don't need to take any additional steps as exernal-dns will scan Ingress objects for hostnames and will create appropriate DNS entires but if you are using LoadBalancer services you'll need to annotate those services to allow external-dns to set up DNS records. The two scripts, ext-dns-<uaa/cf>-svc-annotate.sh do just that. You'll need to run the scripts after the k8s services have been deployed from the UAA and SCF charts. 

- If you'd like, uou can use cert-manager (https://github.com/jetstack/cert-manager) for automated setup of certificates. 
See the e2e-cap-deploy branch for examples of an end-to-end CAP deployment that uses LE to provision certificates for AKS and GKE. 

