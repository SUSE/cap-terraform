#
# Outputs
#
output "path-to-kubeconfig" {
  value = var.kubeconfig_file_path
}

output "aws-route53-hostedzone-policy" {
  value = module.eks.aws_route53_hosted_zone_policy
}

