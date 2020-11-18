module "network" {
  source = "./cluster/network"
}

module "eks" {
  source = "./cluster/eks"

  cluster_name     = module.network.generated-cluster-name
  vpc-id           = module.network.vpc_id
  app_subnet_ids   = module.network.app_subnet_ids
  instance_type    = var.instance_type
  instance_count   = var.instance_count
  keypair_name     = var.keypair_name
  k8s_version      = var.k8s_version
  hosted_zone_name = var.hosted_zone_name
  cluster_labels   = var.cluster_labels
  disk_size_gb     = var.disk_size_gb


}

module "k8sresources" {
  source = "./cluster/k8sresources"

  aws_node_arn                               = module.eks.aws-node-arn
  aws_eks_cluster_name                       = module.eks.aws-eks-cluster-name
  aws_eks_cluster_endpoint                   = module.eks.aws-eks-cluster-endpoint
  aws_eks_cluster_certificate_authority_data = module.eks.aws-eks-cluster-certificate-authority-data
  aws_eks_auth_token                         = module.eks.aws-eks-auth-token

}

provider "helm" {
  version = "1.3.2"
  alias   = "helm-common"
  debug   = true

  kubernetes {
    load_config_file = true
    config_path      = "${path.cwd}/kubeconfig"
  }
}


module "helper-charts" {
  source = "./common/helper-charts"

  providers = {
    helm = helm.helm-common
  }

  platform = "eks" //for common helper-charts' tmpl files

  service_provider            = "aws"
  external_dns_aws_access_key = var.access_key_id
  external_dns_aws_secret_key = var.secret_access_key
  hosted_zone_id              = module.eks.hosted_zone_id
  hosted_zone_name            = var.hosted_zone_name
  email                       = var.email
  region                      = var.region


  depends_on = [
    module.k8sresources
  ]
}



 module "kubecf-charts" {
  source = "./common/kubecf-charts"

  providers = {
    helm = helm.helm-common
  }

  cap_domain = var.cap_domain

  # One variable is initially applied to all security contexts,
  # override to create distinct passwords for each context
  cf_admin_password       = var.admin_password
  uaa_admin_client_secret = var.admin_password
  eirini_enabled          = var.eirini_enabled == "true" ? "true" : "false"
  ha_enabled              = var.ha_enabled     == "true" ? "true" : "false"

   depends_on = [
    module.helper-charts
  ] 
} 

provider "helm" {
  version = "1.3.2"
  alias   = "helm-stratos"
  debug   = true

  kubernetes {
    load_config_file = true
    config_path      = "${path.cwd}/kubeconfig"
  }
}

module "stratos-charts" {
  source = "./common/stratos-charts"

  providers = {
    helm = helm.helm-stratos
  }

  cap_domain = var.cap_domain
  cluster_url = module.eks.aws-eks-cluster-endpoint

  # One variable is initially applied to all security contexts,
  # override to create distinct passwords for each context

  uaa_admin_client_secret = var.admin_password
  stratos_admin_password  = var.admin_password
  metrics_admin_password  = var.admin_password

   depends_on = [
    module.kubecf-charts
  ] 
} 
 
