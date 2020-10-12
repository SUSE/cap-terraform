variable "cluster_name" {
  type = string
}

variable "vpc-id" {
  type = string
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "keypair_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "aws-network-dependency-id" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "cluster_labels" {
  type = map(string)
}

variable "disk_size_gb" {
  type = number
}