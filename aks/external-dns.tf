data "helm_repository" "external-dns-repo" {
  name = "external-dns-chart-repo"
  url  = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "external-dns" {
  name  = "cap-external-dns"
  repository = data.helm_repository.external-dns-repo.metadata.0.name
  chart      = "bitnami/external-dns"
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

  depends_on = [azurerm_kubernetes_cluster.k8s]
}

