#
# Variables Configuration
#

variable "region" {
  type = string
}

variable "workstation_cidr_block" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "cluster_labels" {
  type = map(string)
}

variable "hosted_zone_name" {
  type = string
}

variable "chart_values_file" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "kubeconfig_file_path" {
  type = string
}

variable "email" {
  type = string
}

variable "cap_domain" {
  type = string
}

variable "stratos_metrics_config_file" {
  type = string
}


variable "storage_zones" {
  type = string
}

