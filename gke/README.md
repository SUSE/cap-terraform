1. Create a terraform.tfvars (should be in your .gitignore as contains sensitive information) file with the following information
- `project` (GCP project id)
- `location`
- `credentials_json` (JSON contents of the key file for the GCP service account)
- `dns_credentials_json` (JSON contents of the key file for the GCP service account that will do the DNS records setup, can be same as above as long as the account has sufficent rights to do DNS management)
- `cluster_labels` (optional map of key-value pairs)

2. `terraform init`

3. `terraform plan -out <PLAN-path>`

4. `terraform apply plan <PLAN-path>`

5. The `helm install`s should have been triggered as part of step 5. Check the pods in UAA and SCF namespace to make sure they all come up and are ready.
