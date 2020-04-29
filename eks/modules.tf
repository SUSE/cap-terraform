module "network" {
  source = "./modules/network"
}

module "eks" {
  source = "./modules/eks"

  cluster_name              = module.network.generated-cluster-name
  vpc-id                    = module.network.vpc_id
  app_subnet_ids            = module.network.app_subnet_ids
  instance_type             = var.instance_type
  instance_count            = var.instance_count
  aws-network-dependency-id = module.network.aws-network-dependency
  keypair_name              = var.keypair_name
  k8s_version               = var.k8s_version
  hosted_zone_name          = var.hosted_zone_name
  cluster_labels            = var.cluster_labels
  disk_size_gb              = var.disk_size_gb
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
  cap_domain                                 = var.cap_domain
  # One variable is applied to all three security contexts,
  # override to create distinct passwords for each context.
  stratos_admin_password                     = var.admin_password
  uaa_admin_client_secret                    = var.admin_password
  metrics_admin_password                     = var.admin_password
  # AWS credentials
  access_key_id                              = var.access_key_id
  secret_access_key                          = var.secret_access_key
}

