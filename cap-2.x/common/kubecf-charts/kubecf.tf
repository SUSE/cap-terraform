locals {

  chart_values_file           = "${path.module}/kubecf-config-values.yaml"
  kubeconfig_file             = "${path.cwd}/kubeconfig"
  eirini_params               = var.eirini_enabled == "true" ? {name = "install_stacks", value = "{sle15}"}:{}

}

resource "helm_release" "cf-operator" {
  name             = "cf-operator"
  repository       = "https://kubernetes-charts.suse.com"
  chart            = "cf-operator"
  namespace        = "cfo"
  wait             = "true"
  create_namespace = true

  set {
    name  = "global.singleNamespace.name"
    value = "kubecf"
  }

}

//Setting values from a config file as-well-as command line goes against helm best practices 
// but is perhaps unavoidable here to keep things DRY for various domain related settings

resource "helm_release" "kubecf" {
  name             = "kubecf"
  repository       = "https://kubernetes-charts.suse.com"
  chart            = "kubecf"
  namespace        = "kubecf"
  wait             = "false"
  create_namespace = true

  values = [
    file(local.chart_values_file),
  ]

  set {
    name  = "system_domain"
    value = var.cap_domain
  }

  
  set {
    name  = "features.eirini.enabled"
    value = var.eirini_enabled
  }

  dynamic "set" {
    for_each = local.eirini_params

    content {
      name = local.eirini_params["name"]
      value = local.eirini_params["value"]
    }

  }

  set {
    name  = "high_availability"
    value = var.ha_enabled
  }


  set_sensitive {
    name  = "credentials.cf_admin_password"
    value = var.cf_admin_password
  }
  set_sensitive {
    name  = "credentials.uaa_admin_client_secret"
    value = var.uaa_admin_client_secret
  }

  depends_on = [helm_release.cf-operator]

}




resource "null_resource" "wait_for_uaa" {
  provisioner "local-exec" {
    command     = "./common/kubecf-charts/wait_for_uaa.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      DOMAIN_ENDPOINT = var.cap_domain
    }
  }

  depends_on = [helm_release.kubecf]
}
