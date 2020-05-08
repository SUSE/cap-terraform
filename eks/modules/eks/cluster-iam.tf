data "aws_iam_role" "cluster_iam_role" {
    name = var.cluster_role_name
}

resource "aws_iam_instance_profile" "aws-node" {
  name = "${aws_eks_cluster.aws.name}-worker-iam-instance-profile"
  role = var.worker_node_role_name
}
