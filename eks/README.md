## Requirements

1. Terraform v0.12

### Tools

1. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. [jq filter](https://stedolan.github.io/jq/)
3. [aws-cli](https://aws.amazon.com/cli/)
4. [aws-iam-configuration](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
4. [terraform](https://www.terraform.io/)

### Permissions

Make sure that you have the permissions described [here](https://github.com/SUSE/scf/wiki/IAM-Requirements-for-EKS).

**Note**: In order to restrict the IAM permissions for `route53` the script will output policy for the specified hosted zone. You need to create/add this policy to allow external-dns to change record sets.

### Configurations

1. Add an EC2 Key Pairs to be used to join the nodes into the k8s cluster. Make sure that the key pair is created within the same AWS region than the cluster
2. Make sure that you are using a user with no admin rights

## Instructions

1. Copy `terraform.tfvars.sample` to `terraform.tfvars` and substitute appropriate values.
2. In the helm chart values yaml use the following values to allow `cert-manager` to generate certificates for the ingress endpoints:

```
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 1024m
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    certmanager.k8s.io/acme-challenge-type: dns01
    certmanager.k8s.io/acme-dns01-provider: gcp-clouddns-provider
```
If you change the values of the annotations above you'll need to make corresponding changes in the cert-manager setup (see the `cert-manager.tf` template and the associated scripts). Set the value of the `UAA_CA_CERT` key to the PEM encoded value of the Indetrust DST Root CA X3 cert, e.g:

```
UAA_CA_CERT: |
    -----BEGIN CERTIFICATE-----
    .....
```   

3. Run `aws configure` to authenticate to AWS.
4. Run `terraform init` to install required modules.
5. Run `terraform plan -out <path-to-plan>`
6. Run `terraform apply <path-to-plan>` to create the cluster in AWS.
7. Point your `KUBECONFIG` to the printed kubeconfig file path.
8. Make sure `<your-cluster-name>-worker-iam-role>` has the displayed policy attached for changing `route53` record sets.
9. Check the health of the worker nodes with `kubectl get nodes`.
10. Once you're done, destroy your infrastructure with `terraform destroy`. Note that sometimes, the internet gateway does not get detached and deleted even after 15 minutes and times out. If that happens, you'd have to manually delete the VPC and its dependent resources.

**Note**: Make sure that the attached custom `route53` policy is removed before destroying the cluster.