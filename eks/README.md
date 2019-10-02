## Preparation

## Requirements

1. Terraform v0.12

### Tools

1. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. [jq filter](https://stedolan.github.io/jq/)
3. [aws-cli](https://aws.amazon.com/cli/)
4. [aws-iam-configuratio](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
4. [terraform](https://www.terraform.io/)

### Permissions

Make sure that you have the permissions described [here](https://github.com/SUSE/scf/wiki/IAM-Requirements-for-EKS).

### Configurations

1. Add an EC2 Key Pairs to be used to join the nodes into the k8s cluster. Make sure that the key pair is created within the same AWS region than the cluster
2. Make sure that you are using a user with no admin rights

## Instructions

1. run `aws configure` to authenticate to AWS.
2. Run `terraform apply --parallelism=5 <path-to-plan>` to create the cluster in AWS.   Note that setting the `parallelism` flag value to 5 (default=10) reduces the level of concurrency of Terraform making AWS API calls and might help avoid timeouts due AWS throttling API calls.
3. Run `terraform output kubeconfig` to generate the kubeconfig. Point your `KUBECONFIG` env var to this file.
4. Check the health of your workers with `kubectl get nodes`.
5. The deployment also sets up helm and deploys nginx Ingress Controller in the default namespace. You can check the status of the helm deployment by doing a `helm list`.
6. (OPTIONAL) Have a look at [this guide](https://github.com/SUSE/scf/wiki/Deployment-on-Amazon-EKS) for setting up SUSE Cloud Application Platform on top of it.
7. Once you're done, destroy your infrastructure with `terraform destroy`. Note that sometimes, the internet gateway does not get detached and deleted even after 15 minutes and times out. If that happens, you'd have to manually delete the VPC and its dependent resources.
