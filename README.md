# End-to-end CAP deployment for public cloud platforms with Terraform

The goal is to setup a cluster, configure dependencies(storage classes, helm/tiller) and perform helm installs for UAA and SCF. For details on how to use the templates for specific providers see the respective READMEs in the provider directories.

Few general notes:

- The terraform state is stored locally - note the local state file may contain sensitive information (e.g. credentials) so state files should be left out of source control. The other option is to use a remote backend (s3, azure storage accounts) which allows encrypting the state.

- The GKE and AKS templates use external-dns (https://github.com/kubernetes-incubator/external-dns) for automatic setup of DNS A records. Before you can use it you'll need to setup appropriate DNS zones in your cloud DNS provider of choice - the examples here use Azure DNS and GCP Cloud DNS and would require an Azure Service Principal/GCP service account with sufficient permissions to setup DNS records.  

- external-dns can handle DNS records for both Ingress(es) as well as k8s LoadBalancer services. In this end-to-end example we use an Ingress Controller where you don't need to take any additional steps as exernal-dns will scan Ingress objects for hostnames and will create appropriate DNS entires.  

- These examples use cert-manager (https://github.com/jetstack/cert-manager) for automated setup of certificates. There is an example manifest template in the aks and gke directory that uses LetsEncrypt CA for issuing production grade certificates - the template file has placeholders that will need to be filled in with appropriate information (e.g., azure SP information, subscription, tenant/GCP project id, GCP service account info etc.) to get them operational. Note that with the LE production CA you might encounter rate limiting - see the cert-manager docs for details. The production grade server certs are signed by the Identrust Root CA X3 (https://www.identrust.com/dst-root-ca-x3) - you'll need to use the PEM-encoded value of this certificate as UAA_CA_CERT in your helm chart values used by the SCF chart install.

- The helm chart values file will need to set `ingress.enabled=true` to trigger the deployment of UAA and SCF ingress resources.

