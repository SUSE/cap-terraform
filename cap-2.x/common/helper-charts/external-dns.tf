resource "helm_release" "external-dns" {
  name       = "cap-external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  wait       = "false"

// Common parameters
  set {
    name  = "provider"
    value = var.service_provider
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }

// GKE parameters
  set {
    name  = "google.project"
    value = var.project
  }
  set {
    name  = "google.serviceAccountSecret"
    value = var.dns_credentials_json_secret_key_name
  }

// Azure parameters
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

}

