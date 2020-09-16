resource "helm_release" "external-dns" {
  name  = "cap-external-dns"
  repository = "https://marketplace.azurecr.io/helm/v1/repo"
  chart      = "external-dns"
  wait  = "false"

  set {
    name  = "provider"
    value = "azure"
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
  set {
    name  = "azure.resourceGroup"
    value = var.dns_zone_resource_group
  }
  set {
    name  = "azure.tenantId"
    value = var.tenant_id
  }
  set {
    name  = "azure.subscriptionId"
    value = var.subscription_id
  }
  set {
    name  = "azure.aadClientId"
    value = var.client_id
  }
  set {
    name  = "azure.aadClientSecret"
    value = var.client_secret
  }
  set {
    name  = "rbac.create"
    value = "true"
  }

}

