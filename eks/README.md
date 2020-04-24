## Preparation

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

You also need to set up a Route53 hosted zone where DNS records will be created by `external-dns`. You need to provide the zone id, zone name and an IAM policy ARN that grants sufficient rights to create the DNS records only within that zone. A sample policy declaration is:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/zone-id"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```

### Configurations

1. Add an EC2 Key Pairs to be used to join the nodes into the k8s cluster. Make sure that the key pair is created within the same AWS region than the cluster
2. Make sure that you are using a user with no admin rights

## Instructions

1. run `aws configure` to authenticate to AWS. You should not use the root user account.
2. Run `terraform plan -out <path-to-plan>`
3. Run `terraform apply <path-to-plan>` to create the cluster in AWS.
4. Run `terraform output kubeconfig` to generate the kubeconfig. Point your `KUBECONFIG` env var to this file.
5. Check the health of the worker nodes with `kubectl get nodes`.
6. The deployment also installs nginx Ingress Controller and `external-dns` in the default namespace. You can check the status of the helm deployment by doing a `helm list`.
7. (OPTIONAL) Have a look at [this guide](https://github.com/SUSE/scf/wiki/Deployment-on-Amazon-EKS) for setting up SUSE Cloud Application Platform on top of it.
8. Once you're done, destroy your infrastructure with `terraform destroy`. 
