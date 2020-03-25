
data "aws_iam_policy_document" "worker-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "aws-node" {
  name = "${aws_eks_cluster.aws.name}-worker-iam-role"

  assume_role_policy = data.aws_iam_policy_document.worker-role-policy.json
}

resource "aws_iam_role_policy_attachment" "aws-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.aws-node.name
}

resource "aws_iam_role_policy_attachment" "aws-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws-node.name
}

resource "aws_iam_role_policy_attachment" "aws-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.aws-node.name
}

#resource "aws_iam_role_policy_attachment" "worker-ext-dns-policy" {
#  policy_arn = "${aws_iam_policy.ext-dns-policy.arn}"
#  role       = "${aws_iam_role.aws-node.name}"
#}

resource "aws_iam_instance_profile" "aws-node" {
  name = "${aws_eks_cluster.aws.name}-worker-iam-instance-profile"
  role = aws_iam_role.aws-node.name
}
