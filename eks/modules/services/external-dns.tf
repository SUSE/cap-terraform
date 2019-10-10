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
        value = "${data.aws_route53_zone.selected.zone_id}"
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
