variable "cap_domain" {
  description = "The FQDN of your cluster"
  type = string
}

variable "cf_admin_password" {
  description = "Password for 'admin' user via 'cf' API"
  type = string
}

variable "eirini_enabled" {
  default = "true"
  description = "Eirini enabled?"
  type = string
}

variable "ha_enabled" {
  default = "false"
  description = "HA enabled?"
  type = string
}

variable "uaa_admin_client_secret" {
  description = "Secret for 'admin' user via UAA OAuth client"
  type = string
}
