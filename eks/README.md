This recipe automates setup of an Elastic Kubernetes Service (EKS) on AWS. It was created to simplify deployment of [SUSE Cloud Foundry](https://github.com/SUSE/scf) which takes Kubernetes as a foundation.

## Preparation

### Tools

1. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. [jq filter](https://stedolan.github.io/jq/)
3. [aws-cli](https://aws.amazon.com/cli/)
4. [aws-iam-configuratio](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
4. [terraform](https://www.terraform.io/)

### Permissions

Not quite sure what to say here but I will add something in future. For now just make sure that you have the permissions described [here](https://github.com/SUSE/scf/wiki/IAM-Requirements-for-EKS).

### Configurations

1. Add an EC2 Key Pairs to be used to join the nodes into the k8s cluster
2. Make sure that you are using a user with no admin rights

## Instructions

:warning: Please note the SCF specific security groups in `eks/terraform/eks-worker.tf`

1. run `aws configure` to authenticate to AWS
2. Copy `terraform.tfvars.template` to `terraform.tfvars` and edit the values.
3. Run `terraform apply -var-file=<filename>.tfvars` to create the cluster in AWS
4. Make sure you have the [latest `kubectl` ready](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
5. Make sure you have the [latest `helm` ready](https://github.com/helm/helm/releases).
6. Make sure you have the [`aws-iam-authenticator` binary ready](https://github.com/kubernetes-sigs/aws-iam-authenticator).
7. Check the health of your workers with `kubectl get nodes`.
8. (OPTIONAL) Have a look at [this guide](https://github.com/SUSE/scf/wiki/Deployment-on-Amazon-EKS) for setting up SUSE Cloud Application Platform on top of it.
