1. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
- project (GCP project id)
- location 
- node-pool-name 
- gke_sa_key (location of the key file for the GCP service account)
- gcp_dns_sa_key (location of the key file for the GCP service account that will do the DNS records setup, can be same as above as long as the account has sufficent rights to do DNS management)
- cluster_labels (optional map of key-value pairs)

3. `terraform init`

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`
  