resource "random_string" "cluster_name" {
  length  = 8
  special = false
  upper   = false
  number  = false
}