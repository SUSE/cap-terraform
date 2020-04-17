module "network" {
  source = "./modules/network"
}

module "eks" {
  source = "./modules/eks"

  cluster_name              = module.network.generated-cluster-name
  vpc-id                    = module.network.vpc_id
  app_subnet_ids            = module.network.app_subnet_ids
  workstation_cidr_block    = var.workstation_cidr_block
  instance_type             = var.instance_type
  instance_count            = var.instance_count
  aws-network-dependency-id = module.network.aws-network-dependency
  keypair_name              = var.keypair_name
  k8s_version               = var.k8s_version
  hosted_zone_name          = var.hosted_zone_name
  cluster_labels            = var.cluster_labels
}

module "services" {
  source = "./modules/services"

  aws-eks-cluster-name                       = module.eks.aws-eks-cluster-name
  aws-eks-cluster-endpoint                   = module.eks.aws-eks-cluster-endpoint
  aws-eks-cluster-certificate-authority-data = module.eks.aws-eks-cluster-certificate-authority-data
  worker-arn                                 = module.eks.aws-node-arn
  force-eks-dependency-id                    = module.eks.force-eks-dependency-id
  region                                     = var.region
  hosted_zone_name                           = var.hosted_zone_name
  hosted_zone_id                             = module.eks.hosted_zone_id
  kubeconfig_file_path                       = local.kubeconfig_file_path
  email                                      = var.email
  cap_domain				     = var.cap_domain
  storage_zones				     = var.storage_zones
}

