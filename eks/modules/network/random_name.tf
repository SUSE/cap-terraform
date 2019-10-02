resource "random_string" "cluster_name" {
  length  = 12
  special = false
  upper   = false
  number  = false
}