/* data "aws_iam_policy_document" "ext-dns-iam" {
  statement {
    sid = "1"

    actions = [
    "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ext-dns-policy" {
  name   = "${var.cluster-name}-ext-dns-iam-policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ext-dns-iam.json}"
} */

