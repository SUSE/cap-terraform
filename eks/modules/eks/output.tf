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

output "force-eks-dependency-id" {
    value = "${null_resource.force-wait-on-eks.id}"
}

output "hosted_zone_id" {
    value = "${data.aws_route53_zone.selected.zone_id}"
}
