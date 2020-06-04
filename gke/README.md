1. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
- `project` (GCP project id)
- `location` 
- `node-pool-name` 
- `gke_sa_key` (location of the key file for the GCP service account)
- `gcp_dns_sa_key` (location of the key file for the GCP service account that will do the DNS records setup, can be same as above as long as the account has sufficent rights to do DNS management)
- `cluster_labels` (optional map of key-value pairs)

2. Make appropriate substituions in the `le-prod-cert-issuer.yaml.template` and rename it to `le-prod-cert-issuer.yaml`.

3. In the helm chart values yaml use the following values to allow `cert-manager` to generate certificates for the ingress endpoints:

```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 1024m
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    certmanager.k8s.io/acme-challenge-type: dns01
    certmanager.k8s.io/acme-dns01-provider: gcp-clouddns-provider
```
If you change the values of the annotations above you'll need to make corresponding changes in the cert-manager setup (see the `cert-manager.tf` template and the associated scripts)
Set the value of the `UAA_CA_CERT` key to the PEM encoded value of the Indetrust DST Root CA X3 cert, e.g.,

```
UAA_CA_CERT: |
    -----BEGIN CERTIFICATE-----
    .....
    -----END CERTIFICATE-----
```

4. `terraform init`

5. `terraform plan -out <PLAN-path>`

6. `terraform apply plan <PLAN-path>`

7. The `helm install`s should have been triggered as part of step 5. Check the pods in UAA and SCF namespace to make sure they all come up and are ready. 
  