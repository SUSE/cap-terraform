
resource "kubernetes_secret" "azure_dns_sp_creds" {
  metadata {
    name = "azure-dns-sp-creds"
  }

  data = {
    "azure.json" = file(var.azure_dns_json)
  }
}

data "helm_repository" "external-dns-repo" {
  name = "external-dns-chart-repo"
  url  = "https://charts.bitnami.com/bitnami"
}


resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    repository = data.helm_repository.external-dns-repo.metadata[0].url
    chart = "external-dns"
    wait = "false"

    set {
        name = "azure.secretName"
        value = kubernetes_secret.azure_dns_sp_creds.metadata.0.name
    }
    set {
        name = "provider"
        value = "azure"
    }

    set {
        name = "azure.resourceGroup"
        value = var.dns_zone_rg
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    set {
      name = "policy"
      value = "sync"
    }

    set {
        name = "txtOwnerId"
        value = var.cluster_name
    }

    depends_on = [kubernetes_secret.azure_dns_sp_creds]
}

