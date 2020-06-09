
resource "helm_release" "external-dns" {
  name  = "cap-external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "external-dns"
  wait  = "false"

  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name = "aws.credentials.accessKey"
    value = var.access_key_id
  }
  set {
    name = "aws.credentials.secretKey"
    value = var.secret_access_key
  }
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  set {
    name  = "txtOwnerId"
    value = var.hosted_zone_id
  }
  set {
    name  = "domainFilters[0]"
    value = var.hosted_zone_name
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }


    depends_on = [kubernetes_config_map.aws_auth]

}
