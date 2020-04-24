data "helm_repository" "external-dns-repo" {
  name = "external-dns-chart-repo"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    repository = data.helm_repository.external-dns-repo.metadata[0].name
    chart = "bitnami/external-dns"
    wait = "false"

    set {
        name = "provider"
        value = "aws"
    }

    set {
        name = "aws.zoneType"
        value = "public"
    }

    set {
        name = "aws.preferCNAME"
        value = "true"
    }

    set {
        name = "txtPrefix"
        value = "ext-dns"
    }

    set {
        name = "txtOwnerId"
        value = var.hosted_zone_id
    }

    set {
        name = "domainFilters[0]"
        value = var.hosted_zone_name
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    depends_on = [kubernetes_config_map.aws_auth]
}