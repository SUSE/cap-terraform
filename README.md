# Provision public cloud k8s clusters with Terraform for CAP deployment

The goal is to setup a cluster and configure it such that all that's needed for CAP deployment is the helm installs. For details on how to use the templates for specific providers see the respective READMEs in the provider directories.

Few general notes:

- The terraform state is stored locally for EKS and GKE. The AKS examples show how to use a remote terraform backend (an Azure storage account). The same idea can be used for other providers.

- The GKE and AKS templates use external-dns (https://github.com/kubernetes-incubator/external-dns) for automatic setup of DNS A records and CNAMEs. Before you can use it you'll need to setup appropriate DNS zones in your cloud DNS provider of choice - the examples here use GCP Cloud DNS and would require a GCP service account with sufficient permissions to setup DNS records. You can modify them to use AWS or Azure DNS as well - check the external-dns docs for details. 

- external-dns can handle DNS records for both Ingress(es) as well as k8s LoadBalancer services. If you are using Ingress you don't need to take any additional steps as exernal-dns will scan Ingress objects for hostnames and will create appropriate DNS entires but if you are using LoadBalancer services you'll need to annotate those services to allow external-dns to set up DNS records. The two scripts, ext-dns-<uaa/cf>-svc-annotate.sh do just that. You'll need to run the scripts after the k8s services have been deployed. 

- If you'd like, uou can use cert-manager (https://github.com/jetstack/cert-manager) for automated setup of certificates. There is an example manifest in the gke directory that uses LetsEncrypt staging CA for issuing certificates but there are a number of steps that will need to be performed manually before certificates can be issued. See the cert-manager documentation for details. 

