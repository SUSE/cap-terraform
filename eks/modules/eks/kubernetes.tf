data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.cluster_name} | jq -r -c .status"]
}

provider "kubernetes" {
  version = "~> 1.5"
  load_config_file = false
  host = "${aws_eks_cluster.eks-cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.eks-cluster.certificate_authority.0.data)}"
  token = "${data.external.aws_iam_authenticator.result.token}"
}