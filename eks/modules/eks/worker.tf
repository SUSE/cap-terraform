#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.aws.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  aws-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.aws.endpoint}' --b64-cluster-ca '${aws_eks_cluster.aws.certificate_authority.0.data}' '${aws_eks_cluster.aws.name}'
USERDATA
}

resource "null_resource" "satisfy-aws-network-dependency" {
  provisioner "local-exec" {
    command = "echo ${var.aws-network-dependency-id} > /dev/null"
  }
}

resource "aws_launch_configuration" "aws" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.aws-node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = var.instance_type
  name_prefix                 = "${var.cluster_name}-worker-launch-config"
  security_groups             = [aws_security_group.aws-node.id]
  user_data_base64            = base64encode(local.aws-node-userdata)
  key_name                    = var.keypair_name

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.disk_size_gb
    delete_on_termination = true
  }

  depends_on = [
    null_resource.satisfy-aws-network-dependency,
    aws_security_group_rule.aws-node-ingress-self,
    aws_security_group_rule.aws-node-ingress-cluster
  ]
}

resource "aws_autoscaling_group" "aws" {
  desired_capacity     = var.instance_count
  launch_configuration = aws_launch_configuration.aws.id
  max_size             = var.instance_count
  min_size             = var.instance_count
  name                 = var.cluster_name
  vpc_zone_identifier  = var.app_subnet_ids

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

}

resource "null_resource" "force-wait-on-eks" {
  depends_on = [aws_autoscaling_group.aws]
}
