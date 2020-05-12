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

The setup depends on 3 pre-defined IAM roles two of which must exist before the setup is attempted. 

1. A role that EKS service (`cluster_role` in the parameters section below) can assume with the following attached policies:
    - AmazonEKSClusterPolicy
    - AmazonEKSServicePolicy

2. The EC2 service running the worker nodes (`worker_node_role` role in the parameters section below) need to assume a role that has the following attached policies:

    - AmazonEKSWorkerNodePolicy
    - AmazonEKS_CNI_Policy
    - AmazonEC2ContainerRegistryReadOnly

3. Finally, should you choose to  run the deployer as a separate IAM role (e.g. deployer) the deployer role must have the following attached policies:

```
autoscaling/CreateAutoScalingGroup
autoscaling/DeleteAutoScalingGroup
autoscaling/DescribeAutoScalingGroups
autoscaling/UpdateAutoScalingGroup
ec2/AssociateRouteTable
ec2/AttachInternetGateway
ec2/AuthorizeSecurityGroupEgress
ec2/AuthorizeSecurityGroupIngress
ec2/CreateInternetGateway
ec2/CreateLaunchTemplate
ec2/CreateRoute
ec2/CreateRouteTable
ec2/CreateSecurityGroup
ec2/CreateSubnet
ec2/CreateTags
ec2/CreateVpc
ec2/DeleteInternetGateway
ec2/DeleteLaunchTemplate
ec2/DeleteRouteTable
ec2/DeleteSecurityGroup
ec2/DeleteSubnet
ec2/DeleteVpc
ec2/DescribeAccountAttributes
ec2/DescribeAvailabilityZones
ec2/DescribeImages
ec2/DescribeInternetGateways
ec2/DescribeLaunchTemplateVersions
ec2/DescribeLaunchTemplates
ec2/DescribeNetworkAcls
ec2/DescribeNetworkInterfaces
ec2/DescribeRouteTables
ec2/DescribeSecurityGroups
ec2/DescribeSubnets
ec2/DescribeVpcAttribute
ec2/DescribeVpcClassicLink
ec2/DescribeVpcClassicLinkDnsSupport
ec2/DescribeVpcs
ec2/DetachInternetGateway
ec2/DisassociateRouteTable
ec2/RevokeSecurityGroupEgress
ec2/RevokeSecurityGroupIngress
eks/CreateCluster
eks/DeleteCluster
eks/DescribeCluster
iam/AddRoleToInstanceProfile
iam/CreateInstanceProfile
iam/DeleteInstanceProfile
iam/GetInstanceProfile
iam/GetRole
iam/RemoveRoleFromInstanceProfile
sts/GetCallerIdentity
```

If you choose not to use a separate IAM role the account running the setup must have sufficient rights as outlined above. However, it is recommended to run the setup as a deployer role and the account running the setup must have a trust relationship to be able to assume this role.


You also need to set up a Route53 hosted zone where DNS records will be created by `external-dns`. The `external-dns` setup expects an access_key_id and secret_key that should have appropriate rights to create
DNS records in a hosted zone in Route53 as in the following

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

1. run `aws configure` to authenticate to AWS. You should not use the root user account. See note above about using a pre-defined IAM role for the deployer.
2. Run `terraform plan -out <path-to-plan>`
3. A sample terraform.tfvars is:
```
region = "us-east-2"
keypair_name = "test-keys"
eks_version = "1.16"
cluster_name = "cluster-name"
cluster_labels = {"key" = "value"}
instance_type="t2.large"
hosted_zone_name="hosted-route53-zone"
deployer_role_arn = "arn:aws:iam::xxxxxxxx:role/Deployer"
cluster_role_name = "Deployer"
cluster_role_arn = "arn:aws:iam::xxxxxxx:role/Cluster"
worker_node_role_name = "WorkerNode"
worker_node_role_arn  = "arn:aws:iam::xxxxxxx:role/WorkerNode"
kube_authorized_role_arn = "arn:aws:iam::xxxxxxxxx:role/kube_authorized_role"
```
The `kube_authorized_role_arn` is an optional parameter you can specify to allow users that can assume this role to have `kubectl` access to the cluster as `admin` users.

4. Run `terraform apply <path-to-plan>` to create the cluster in AWS.
5. Run `terraform output kubeconfig` to generate the kubeconfig. Point your `KUBECONFIG` env var to this file.
6. Check the health of the worker nodes with `kubectl get nodes`.
7. The deployment also installs nginx Ingress Controller and `external-dns` in the default namespace. You can check the status of the helm deployment by doing a `helm list`.
8. (OPTIONAL) Have a look at [this guide](https://github.com/SUSE/scf/wiki/Deployment-on-Amazon-EKS) for setting up SUSE Cloud Application Platform on top of it.
9. Once you're done, destroy your infrastructure with `terraform destroy`. Note, sometimes security groups
may fail to delete due to a known issue with the AWS Terraform provider as documented here:
https://github.com/terraform-providers/terraform-provider-aws/issues/2445

But usually, running the `destroy` a second time clears things up.
