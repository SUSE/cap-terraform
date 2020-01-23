
resource "kubernetes_secret" "azure_dns_sp_creds" {
  metadata {
    name = "azure-dns-sp-creds"
  }

}  


resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"
    wait = "false"

    set {
        name = "aws.credentials.mountPath"
        value = "/home/xxxxxxxxx/.aws"
    }
    set {
        name = "provider"
        value = "aws"
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "aws.zoneType"
        value = "public"
    }
   
    set {
        name = "txtOwnerId"
        value = "xxxxxxx"
    }

    set {
        name = "aws.credentials.accessKey"
        value = "xxxxxxxxx"
    }

    set {
        name = "aws.credentials.secretKey"
        value = "xxxxxxxxx"
    }


    set {
        name = "domainFilters[0]"
        value = "xxxxxxxxx.xxxxxxxxx"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}
