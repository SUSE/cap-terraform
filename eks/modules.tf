module "network" {
    source = "./modules/network"
}

module "eks" {
    source = "./modules/eks"

    cluster_name  = "${module.network.generated-cluster-name}"
    vpc-id = "${module.network.vpc_id}"
    app_subnet_ids = "${module.network.app_subnet_ids}"
    workstation_cidr_block = "${var.workstation_cidr_block}"
    aws-network-dependency-id = "${module.network.aws-network-dependency}"
    keypair_name = "${var.keypair_name}"
    eks_version = "${var.eks_version}"
    hosted_zone_name = "${var.hosted_zone_name}"
    cluster_labels = "${var.cluster_labels}"
}

module "services" {
    source = "./modules/services"

    aws-eks-cluster-name = "${module.eks.aws-eks-cluster-name}"
    aws-eks-cluster-endpoint = "${module.eks.aws-eks-cluster-endpoint}"
    aws-eks-cluster-certificate-authority-data = "${module.eks.aws-eks-cluster-certificate-authority-data}"
    worker-arn = "${module.eks.aws-node-arn}"
    force-eks-dependency-id = "${module.eks.force-eks-dependency-id}"
    region = "${var.region}"
    hosted_zone_name = "${var.hosted_zone_name}"
    hosted_zone_id = "${module.eks.hosted_zone_id}"
    chart_values_file = "${var.chart_values_file}"
    kubeconfig_file_path = "${var.kubeconfig_file_path}"
    email = "${var.email}"
}
