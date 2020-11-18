data aws_eks_cluster_auth "eks_auth"{
    name = aws_eks_cluster.aws.name

}

output "aws-node-arn" {
  value = "${aws_iam_role.aws-node.arn}"
}

output "aws-eks-cluster-name" {
  value = "${aws_eks_cluster.aws.name}"
}

output "aws-eks-cluster-endpoint" {
  value = "${aws_eks_cluster.aws.endpoint}"
}

output "aws-eks-cluster-certificate-authority-data" {
  value = "${aws_eks_cluster.aws.certificate_authority.0.data}"
}

output "aws-eks-auth-token" {
    value = data.aws_eks_cluster_auth.eks_auth.token
}

output "hosted_zone_id" {
  value = "${data.aws_route53_zone.selected.zone_id}"
}

output "aws_route53_hosted_zone_policy" {
  value = "${data.aws_iam_policy_document.route53-restricted-update-policy.json}"
}
