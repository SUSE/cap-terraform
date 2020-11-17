variable "cap_domain" {
  description = "The FQDN of your cluster"
  type = string
}

variable "cluster_url" {
  description = "Cluster APIServer URL"
  type = string
}

variable "metrics_admin_password" {
  description = "Password for 'admin' user in Stratos-Metrics"
  type = string
}

variable "stratos_admin_password" {
  description = "Password for 'admin' user in Stratos"
  type = string
}

variable "uaa_admin_client_secret" {
  description = "Secret for 'admin' user via UAA OAuth client"
  type = string
}
