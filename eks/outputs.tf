#
# Outputs
#
locals {
  kubeconfig_file_path = "${path.cwd}/kubeconfig"
}

output "path-to-kubeconfig" {
  value = local.kubeconfig_file_path
}

output "aws-route53-hostedzone-policy" {
  value = module.eks.aws_route53_hosted_zone_policy
}
