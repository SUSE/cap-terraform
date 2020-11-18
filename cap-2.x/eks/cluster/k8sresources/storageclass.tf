// Add a storage class resource with name "persistent"
resource "kubernetes_storage_class" "persistent" {
  metadata {
    name = "persistent"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  parameters = {
    type = "gp2"
  }
  depends_on = [kubernetes_config_map.aws_auth]
}
resource "kubernetes_storage_class" "scopedpersistent" {
  metadata {
    name = "scopedpersistent"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  parameters = {
    type = "gp2"
  }
  depends_on = [kubernetes_config_map.aws_auth]
}
