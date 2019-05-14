# Security group rules general and CAP-specific (please test)

resource "aws_security_group_rule" "eks-worker-ingress-workers" {
  description              = "Allow workers to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-worker.id}"
  source_security_group_id = "${aws_security_group.eks-worker.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-worker.id}"
  source_security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# CAP specifics

resource "aws_security_group_rule" "eks-worker-ingress-cap-http" {
  description              = "Allow CloudFoundry to communicate on http port"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}

resource "aws_security_group_rule" "eks-worker-ingress-cap-https" {
  description              = "Allow CloudFoundry to communicate on https port"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}

resource "aws_security_group_rule" "eks-worker-ingress-cap-uaa" {
  description              = "Allow CloudFoundry to communicate for UAA"
  type                     = "ingress"
  from_port                = 2793
  to_port                  = 2793
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}

resource "aws_security_group_rule" "eks-worker-ingress-cap-ssh" {
  description              = "Allow CloudFoundry to communicate for SSH"
  type                     = "ingress"
  from_port                = 2222
  to_port                  = 2222
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}

resource "aws_security_group_rule" "eks-worker-ingress-cap-wss" {
  description              = "Allow CloudFoundry to communicate for WSS"
  type                     = "ingress"
  from_port                = 4443
  to_port                  = 4443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}
resource "aws_security_group_rule" "eks-cluster-ingress-workers-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-worker.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-worker-ingress-stratos" {
  description              = "Allow access to Stratos UI"
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}

resource "aws_security_group_rule" "eks-worker-ingress-cap-brains" {
  description              = "Allow CloudFoundry to communicate for CAP Brains"
  type                     = "ingress"
  from_port                = 20000
  to_port                  = 20009
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  security_group_id        = "${aws_security_group.eks-worker.id}"
}