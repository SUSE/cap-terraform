
variable "aws-eks-cluster-name" {
    type = "string"
}

variable "aws-eks-cluster-endpoint" {
    type = "string"
}

variable "aws-eks-cluster-certificate-authority-data" {
    type = "string"
}

variable "worker-arn" {
    type = "string"
}

variable "force-eks-dependency-id" {
    type = "string"
}

variable "region" {
    type = "string"
}

variable "hosted_zone_id" {
    type = "string"
}

variable "hosted_zone_name" {
    type = "string"
}

variable "chart_values_file" {
    type = "string"
}

variable "kubeconfig_path" {
  type = "string"
}
