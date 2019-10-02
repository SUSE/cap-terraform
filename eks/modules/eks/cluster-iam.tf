
#  * IAM Role to allow EKS service to manage other AWS services
data "aws_iam_policy_document" "cluster-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "aws-cluster" {
  name = "${var.generated-cluster-name}-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.cluster-role-policy.json}"
  
}

resource "aws_iam_role_policy_attachment" "aws-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.aws-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "aws-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.aws-cluster.name}"
}
