output "aws-node-arn" {
    value = "${aws_iam_role.aws-node.arn}"
}

output "eks-cluster-name" {
   value = "${aws_eks_cluster.aws.name}"
}

output "force-eks-dependency-id" {
    value = "${null_resource.force-wait-on-eks.id}"
}
