variable "client_id" {
  default = ""
  description = "Azure Service Principal 'appId'"
  type = string
}

variable "client_secret" {
  default = ""
  description = "Azure Service Principal 'password'"
  type = string
}

variable "dns_credentials_json_secret_key_name" {
  default = "{}"
  description = "Secret key name, with value being the contents of a service account key file in JSON format, with rights to edit DNS."
  type = string
}

variable "dns_zone_name" {
  default = ""
  description = "Name of the Azure DNS Zone created for the cluster."
  type = string
}

variable "dns_zone_resource_group" {
  default = ""
  description = "An existing Azure Resource Group where your Azure DNS Zone is hosted."
  type = string
}

variable "email" {
  description = "Email address to send TLS certificate notifications to."
  type = string
}

variable "external_dns_aws_access_key" {
  default = ""
  description = "AWS access key for setting route53 DNS records"
  type = string
}

variable "external_dns_aws_secret_key" {
  default = ""
  description = "AWS secret key for setting route53 DNS records"
  type = string
}

variable "hosted_zone_id" {
  default = ""
  description = "Route53 hosted zone id"
  type = string
}

variable "hosted_zone_name" {
  default = ""
  description = "Route53 hosted zone name"
  type = string
}

variable "platform" {
  description = "Platform name, to select platform specific files to be used"
  type = string
}

variable "project" {
  default = ""
  description = "The GCP project to manage resources in."
  type = string
}

variable "region" {
  default = ""
  description = "Region for cert-manager DNS01 Route53 solver."
  type = string
}

variable "service_provider" {
  default = ""
  description = "Provider for external-dns"
  type = string
}

variable "subscription_id" {
  default = ""
  description = "Azure subscription ID"
  type = string
}

variable "tenant_id" {
  default = ""
  description = "Azure Service Principal 'tenant'"
  type = string
}
