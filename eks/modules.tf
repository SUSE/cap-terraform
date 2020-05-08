module "network" {
  source = "./modules/network"
}

module "eks" {
    source = "./modules/eks"

    generated-cluster-name  = module.network.generated-cluster-name
    cluster_name            = var.cluster_name
    vpc-id      = module.network.vpc_id
    app_subnet_ids = module.network.app_subnet_ids
    aws-network-dependency-id = module.network.aws-network-dependency
    keypair_name  = var.keypair_name
    eks_version   = var.eks_version
    cluster_role_name = var.cluster_role_name
    cluster_role_arn = var.cluster_role_arn
    worker_node_role_name = var.worker_node_role_name
    cluster_labels = var.cluster_labels
    instance_type  = var.instance_type
}

module "services" {
    source = "./modules/services"

    eks-cluster-name = module.eks.eks-cluster-name
    worker-arn      = var.worker_node_role_arn
    force-eks-dependency-id = module.eks.force-eks-dependency-id
    hosted_zone_name = var.hosted_zone_name
    external_dns_aws_access_key = var.external_dns_aws_access_key
    external_dns_aws_secret_key = var.external_dns_aws_secret_key
    kube_authorized_role_arn = var.kube_authorized_role_arn


}
