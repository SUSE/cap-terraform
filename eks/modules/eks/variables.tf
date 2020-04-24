variable "generated-cluster-name" {
  type = string
}

variable "vpc-id" {
  type = string
}

variable "instance_type" {
    type = string
}

variable "app_subnet_ids" {
  type = list(string)
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

variable "hosted_zone_policy_arn" {
  type = string
}


variable "aws-network-dependency-id" {
  type = string
}

variable "cluster_labels" {
  type = map
}


