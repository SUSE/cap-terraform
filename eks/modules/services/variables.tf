
variable "eks-cluster-name" {
    type = string
}

variable "worker-arn" {
    type = string
}

variable "force-eks-dependency-id" {
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

variable "external_dns_aws_access_key" {
    type = string
}

variable "external_dns_aws_secret_key" {
    type = string
}
