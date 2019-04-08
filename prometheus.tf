resource "helm_release" "prometheus" {
  chart     = "stable/prometheus"
  name      = "cap-prometheus"
  namespace = "prometheus"

  depends_on = ["kubernetes_cluster_role_binding.tiller"]
}