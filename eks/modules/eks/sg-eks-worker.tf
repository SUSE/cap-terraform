resource "aws_security_group" "eks-worker" {
  name        = "${var.cluster_name}-worker"
  description = "Security group for all workers in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.cluster_name}-worker",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}
