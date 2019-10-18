#
# Variables Configuration
#

variable "region" {
    type = "string"
}

variable "workstation_cidr_block" {
    type = "string"
}

variable "keypair_name" {
    type = "string"
}

variable "eks_version" {
    type = "string"
}

variable "cluster_labels" {
    type = "map"
}

variable "hosted_zone_name" {
    type = "string"
}

variable "chart_values_file" {
    type = "string"
}

variable "kubeconfig_file_path" {
  type = "string"
}

variable "email" {
  type = "string"
}
