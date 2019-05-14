resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"

    set {
        name = "aws.accessKey"
        value = "${var.access_key}"
    }
    set {
      name = "secretKey"
      value = "${var.secret_key}"
    }
    set {
        name = "aws.region"
        value = "${var.location}"
    }
    set {
      name = "aws.credentialsPath"
      value = "/.aws"
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
        name = "rbac.create"
        value = "true"
    }
    

    //depends_on = ["kubernetes_cluster_role_binding.tiller"]
}