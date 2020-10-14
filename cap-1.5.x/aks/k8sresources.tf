provider "kubernetes" {
  version          = "1.10.0"
  load_config_file = false
  host             = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_storage_class" "akssc" {
  metadata {
    name = "persistent"
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  parameters = {
    storageaccounttype = "Premium_LRS"
    kind               = "managed"
  }
}

