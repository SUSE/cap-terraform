#
# Variables Configuration
#

variable "cluster_name" {
    type  = string
}

variable "region" {
    type  = string
}


variable "keypair_name" {
    type = string
}

variable "eks_version" {
    type = string
}

variable "cluster_labels" {
    type = map
}

variable "instance_type" {
    type = string
    default = "t3.xlarge"
}


variable "hosted_zone_name" {
    type = string
}


variable "deployer_role_arn" {
    type = string
    default = ""
}

variable "cluster_role_name" {
    type = string
}

variable "cluster_role_arn" {
    type = string
}

variable "worker_node_role_name" {
    type = string
}

variable "worker_node_role_arn" {
    type = string
}

variable "external_dns_aws_access_key" {
    type = string
}

variable "external_dns_aws_secret_key" {
    type = string
}

variable "kube_authorized_role_arn" {
    type = string
    default = ""
}
