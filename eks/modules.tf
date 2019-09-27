module "network" {
  source = "./modules/network"

  cluster-name    = "${var.cluster-name}"
}

module "eks" {
    source = "./modules/eks"

    cluster-name  = "${var.cluster-name}"
    vpc-id      = "${module.network.vpc_id}"
    app_subnet_ids = "${module.network.app_subnet_ids}"
    workstation_cidr_block = "${var.workstation_cidr_block}"
    keypair_name  = "${var.keypair_name}"
}

module "services" {
    source = "./modules/services"

    eks-cluster-name = "${module.eks.eks-cluster-name}"
}
