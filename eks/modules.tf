module "network" {
  source = "./modules/network"
}

module "eks" {
    source = "./modules/eks"

    generated-cluster-name  = "${module.network.generated-cluster-name}"
    vpc-id      = "${module.network.vpc_id}"
    app_subnet_ids = "${module.network.app_subnet_ids}"
    workstation_cidr_block = "${var.workstation_cidr_block}"
    aws-network-dependency-id = "${module.network.aws-network-dependency}"
    keypair_name  = "${var.keypair_name}"
    eks_version   = "${var.eks_version}"
    cluster_labels = "${var.cluster_labels}"
}

module "services" {
    source = "./modules/services"

    eks-cluster-name = "${module.eks.eks-cluster-name}"
    worker-arn      = "${module.eks.aws-node-arn}"
    force-eks-dependency-id = "${module.eks.force-eks-dependency-id}"
    region = "${var.region}"
    hosted_zone_name = "${var.hosted_zone_name}"
}
