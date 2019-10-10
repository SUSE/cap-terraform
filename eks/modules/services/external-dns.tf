data "aws_route53_zone" "selected" {
  name = "${var.hosted_zone_name}"
}

data "aws_iam_policy_document" "route53_policy" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${var.hosted_zone_id}"]
  }
}

resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"
    wait = "false"

    set {
        name = "provider"
        value = "aws"
    }

    set {
        name = "provider"
        value = "aws"
    }

    set {
        name = "aws.zoneType"
        value = "public"
    }

    set {
        name = "txtOwnerId"
        value = "${var.hosted_zone_id}"
    }

    set {
        name = "domainFilters[0]"
        value = "${var.hosted_zone_name}"
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}
