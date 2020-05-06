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
}

/*
variable "hosted_zone_id" {
    type = string
}
*/

variable "hosted_zone_name" {
    type = string
}


variable "assume_role_arn" {
    type = string
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
