resource "aws_security_group" "aws-node" {
  name        = "${aws_eks_cluster.aws.name}-worker-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc-id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${aws_eks_cluster.aws.name}-worker-security-group",
     "kubernetes.io/cluster/${aws_eks_cluster.aws.name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "aws-node-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.aws-node.id}"
  source_security_group_id = "${aws_security_group.aws-node.id}"
  to_port                  = 65535
 # to_port                  = 0  //https://www.terraform.io/docs/providers/aws/r/security_group.html#protocol

  type                     = "ingress"
}

resource "aws_security_group_rule" "aws-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.aws-node.id}"
  source_security_group_id = "${aws_security_group.aws-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}
/*
resource "aws_security_group_rule" "aws-node-ingress-cap-http" {
  description              = "Allow CloudFoundry to communicate on http port"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"
}

resource "aws_security_group_rule" "aws-node-ingress-cap-https" {
  description              = "Allow CloudFoundry to communicate on https port"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"

}

  resource "aws_security_group_rule" "aws-node-ingress-cap-uaa" {
  description              = "Allow CloudFoundry to communicate for UAA"
  type                     = "ingress"
  from_port                = 2793
  to_port                  = 2793
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"

}

resource "aws_security_group_rule" "aws-node-ingress-cap-ssh" {
  description              = "Allow CloudFoundry to communicate for SSH"
  type                     = "ingress"
  from_port                = 2222
  to_port                  = 2222
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"
}

resource "aws_security_group_rule" "aws-node-ingress-cap-wss" {
  description              = "Allow CloudFoundry to communicate for WSS"
  type                     = "ingress"
  from_port                = 4443
  to_port                  = 4443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"
}

resource "aws_security_group_rule" "aws-node-ingress-stratos" {
  description              = "Allow access to Stratos UI"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"

}

resource "aws_security_group_rule" "aws-node-ingress-tcp-traffic" {
  description              = "Allow TCP traffc into TCP router"
  type                     = "ingress"
  from_port                = 20000
  to_port                  = 20009
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
#  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.aws-node.id}"
}
*/