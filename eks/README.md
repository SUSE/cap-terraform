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

1. run `aws configure` to authenticate to AWS
2. Run `terraform apply` to create the cluster in AWS
3. Run `terraform output kubeconfig` to generate the kubeconfig. Point your KUBECONFIG env var to point to this file.
4. Run `terraform output config_map_aws_auth > eks_cm.yaml` to generate a configmap to allow workers to join the node. 
5. Run `kubectl apply -f eks_cm.yaml`
6. Check the health of your workers with `kubectl get nodes`.
7. Wait until the nodes are reported as `Ready`.
8. (OPTIONAL) Have a look at [this guide](https://github.com/SUSE/scf/wiki/Deployment-on-Amazon-EKS) for setting up SUSE Cloud Application Platform on top of it.
