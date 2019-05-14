# Default AMI for EKS workers in eu-west-1 (Ireland)

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v25"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

data "aws_region" "current" {}
  
locals {
  eks-worker-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-cluster.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

# Could possibly use a bare ec2 resource here?

resource "aws_launch_configuration" "eks-worker" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks-worker.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.xlarge"
  name_prefix                 = "${var.cluster_name}"
  security_groups             = ["${aws_security_group.eks-worker.id}"]
  user_data_base64            = "${base64encode(local.eks-worker-userdata)}"
  key_name                    = "${var.keypair_name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 60
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "eks-worker" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks-worker.id}"
  max_size             = 4
  min_size             = 2
  name                 = "${var.cluster_name}"
  vpc_zone_identifier  = ["${var.app_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}