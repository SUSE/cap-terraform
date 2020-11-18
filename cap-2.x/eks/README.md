## Required Tools

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [terraform](https://www.terraform.io/) v0.12
* [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

## Prerequisites

* An AWS access key on an account with adequate credentials.
  See https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys for details, and https://documentation.suse.com/suse-cap/1.5.2/html/cap-guides/cha-cap-depl-eks.html#sec-cap-eks-iam for IAM requirements.

* A Route 53 Hosted zone
  The DNS zone will host the cluster's DNS records in a specific domain name. Make note of the _name_ which must be supplied in terraform variables. See https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html for details on setting up a Hosted zone.

* An EC2 Key Pair
  The key pair will be used for accessing cluster nodes via SSH. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html for details on creating a Key Pair.

## Setup

1. Create a `terraform.tfvars` or `terraform.tfvars.json` file with the following information:
    - `instance_count` - The number of worker nodes in your cluster. (Minimum: 3, Maximum 50)
    - `instance_type` - The type of instance used for the provisioned workers.
    - `region` - The AWS region where the cluster and related resources will be created.
    - `access_key_id` - AWS access key ID. See https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys for details.
    - `secret_access_key` - AWS secret access key (password). See https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys for details.
    - `keypair_name` - Name of the EC2 Key Pair used for accessing worker nodes via SSH. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html for details.
    - `admin_password` - Intial password for Cloud Foundry 'admin' user, UAA 'admin' OAuth client, and metrics 'admin' login. We recommend changing this password after deployment. See https://documentation.suse.com/suse-cap/single-html/cap-guides/#cha-cap-manage-passwords
    - `disk_size_gb` - The worker node storage capacity. (Minimum:80, Maximum: 16383)
    - `cluster_labels` - Tags to be applied to resources in your cluster. (Optional)
    - `hosted_zone_name` - Name of the Route 53 Hosted zone created for the cluster.
    - `cap_domain` - The FQDN of your cluster - a subdomain of the Hosted zone.
    - `email` - Email address to send TLS certificate notifications to.
    - `eirini_enabled` - Deploy with Eirini (default = "true") or Diego ("false") (Optional)
    - `ha_enabled`  - Deploy CAP in high availability mode (default = "false") (Optional)

    **⚠** _This file should be in your `.gitignore` or otherwise outside source control as it contains sensitive information._

2. `terraform init`

3. `terraform plan -out <PLAN-path>`

4. `terraform apply <PLAN-path>`

## Results

* A kubeconfig named `kubeconfig` is generated in the same directory TF is run from. Set your `KUBECONFIG` env var to point to this file.

* Make sure `<$YOUR_CLUSTER_NAME-worker-iam-role>` has the displayed policy attached for changing `route53` record sets.

    **⚠** _Make sure that the attached custom `route53` policy is removed before destroying the cluster._

* The `helm install`s should have been triggered as part of step 4. Check the pods in uaa, scf, stratos and metrics namespace to make sure they all come up and are ready.

#### Have a lot of fun!
