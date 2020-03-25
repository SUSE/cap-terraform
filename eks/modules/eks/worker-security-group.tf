resource "aws_security_group" "aws-node" {
  name        = "${aws_eks_cluster.aws.name}-worker-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc-id

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
  security_group_id        = aws_security_group.aws-node.id
  source_security_group_id = aws_security_group.aws-node.id
  to_port                  = 65535
 # to_port                  = 0  //https://www.terraform.io/docs/providers/aws/r/security_group.html#protocol

  type                     = "ingress"
}

resource "aws_security_group_rule" "aws-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aws-node.id
  source_security_group_id = aws_security_group.aws-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}
