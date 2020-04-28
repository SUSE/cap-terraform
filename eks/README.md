### Tools

1. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
1. [terraform](https://www.terraform.io/) v0.12

## Prerequisites

* An AWS access key on an account with adequate credentials. See https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys for details, and https://documentation.suse.com/suse-cap/1.5.2/html/cap-guides/cha-cap-depl-eks.html#sec-cap-eks-iam for IAM requirements.

**Note**: In order to restrict the IAM permissions for `route53` the script will output policy for the specified hosted zone. You need to create/add this policy to allow external-dns to change record sets.

### Configurations

1. Add an EC2 Key Pairs to be used to join the nodes into the k8s cluster. Make sure that the key pair is created within the same AWS region than the cluster
2. Make sure that you are using a user with no admin rights

## Instructions

1. Create `terraform.tfvars` with appropriate values.
1. Run `aws configure` to authenticate to AWS.
1. Run `terraform init` to install required modules.
1. Run `terraform plan -out <path-to-plan>`
1. Run `terraform apply <path-to-plan>` to create the cluster in AWS.
1. Point your `KUBECONFIG` to the printed kubeconfig file path.
1. Make sure `<your-cluster-name>-worker-iam-role>` has the displayed policy attached for changing `route53` record sets.
1. Check the health of the worker nodes with `kubectl get nodes`.
1. Once you're done, destroy your infrastructure with `terraform destroy`. Note that sometimes, the internet gateway does not get detached and deleted even after 15 minutes and times out. If that happens, you'd have to manually delete the VPC and its dependent resources.

**Note**: Make sure that the attached custom `route53` policy is removed before destroying the cluster.