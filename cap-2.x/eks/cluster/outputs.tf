locals {
  kubeconfig_file_path = "${path.cwd}/kubeconfig"
}

#
# Outputs
#

output "path-to-kubeconfig" {
  value = local.kubeconfig_file_path
}

output "aws-route53-hostedzone-policy" {
  value = module.eks.aws_route53_hosted_zone_policy
}

output "uaa_url" {
  value = "https://uaa.${var.cap_domain}/login"
}
output "stratos_url" {
  value = "https://stratos.${var.cap_domain}"
}
output "metrics_url" {
  value = "https://metrics.${var.cap_domain}"
}