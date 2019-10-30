variable "cluster_name" {
  type = "string"
}

variable "vpc-id" {
    type = "string"
}

variable "app_subnet_ids" {
    type = list(string)
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

variable "instance_type" {
    type = "string"
}


variable "aws-network-dependency-id" {
    type = "string"
}

variable "hosted_zone_name" {
    type = "string"
}


variable "cluster_labels" {
    type = "map"
}
