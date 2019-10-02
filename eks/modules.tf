module "network" {
  source = "./modules/network"
}

module "eks" {
    source = "./modules/eks"

    generated-cluster-name  = "${module.network.generated-cluster-name}"
    vpc-id      = "${module.network.vpc_id}"
    app_subnet_ids = "${module.network.app_subnet_ids}"
    workstation_cidr_block = "${var.workstation_cidr_block}"
    keypair_name  = "${var.keypair_name}"
    eks_version   = "${var.eks_version}"
}

module "services" {
    source = "./modules/services"

    eks-cluster-name = "${module.eks.eks-cluster-name}"
    worker-arn      = "${module.eks.aws-node-arn}"
}
