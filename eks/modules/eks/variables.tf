variable "cluster_name" {
  type    = "string"
}
variable "location" {
    description = "Used AWS Region."
}

variable "app_subnet_ids" {
  type = "list"
}

variable "keypair_name" {
  type = "string"
  description = "Name of the keypair declared in AWS IAM, used to connect into your instances via SSH."
}

variable "vpc_id" {
  type = "string"
}