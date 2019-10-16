#
# Outputs
#

output "aws-route53-hostedzone-policy" {
  value = "${module.services.aws_route53_hosted_zone_policy}"
}
