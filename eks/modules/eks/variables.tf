variable "cluster-name" {
  type    = "string"
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