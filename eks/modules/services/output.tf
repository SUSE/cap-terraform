output "hosted_zone_id" {
    value = "${data.aws_route53_zone.selected.zone_id}"
}

output "aws_route53_hosted_zone_policy" {
  value = "${data.aws_iam_policy_document.route53_policy.json}"
}
