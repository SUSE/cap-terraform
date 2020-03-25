#
# Variables Configuration
#

variable "region" {
    type  = string
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
    type = map
}

variable "instance_type" {
    type = string
}
