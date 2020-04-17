resource "aws_security_group" "aws-node" {
  name        = "${var.cluster_name}-worker-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc-id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  revoke_rules_on_delete = true

  tags = map(
    "Name", "${var.cluster_name}-worker-security-group",
    "kubernetes.io/cluster/${var.cluster_name}", "owned",
  )
}

resource "aws_security_group_rule" "aws-node-ingress-self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.aws-node.id
  source_security_group_id = aws_security_group.aws-node.id
  to_port                  = 65535
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
