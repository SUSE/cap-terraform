
variable "aws-eks-cluster-name" {
  type = string
}

variable "aws-eks-cluster-endpoint" {
  type = string
}

variable "aws-eks-cluster-certificate-authority-data" {
  type = string
}

variable "worker-arn" {
  type = string
}

variable "force-eks-dependency-id" {
  type = string
}

variable "region" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}
variable "hosted_zone_id" {
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

variable "stratos_admin_password" {
  type = string
}

variable "uaa_admin_client_secret" {
  type = string
}

variable "metrics_admin_password" {
  type = string
}

variable "access_key_id" {
  type = string
}

variable "secret_access_key" {
  type = string
}