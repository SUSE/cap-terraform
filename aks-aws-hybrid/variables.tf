variable "az_resource_group" {
    type = "string"
}

variable "location" {
    type = "string"
}

variable "node_count" {
    default = "1"
}
variable "machine_type" {
    default = "Standard_DS3_v2"
}

variable "agent_admin" {
    type = "string"
}

variable "dns_prefix" {
    default = "cap-on-aks"
}

variable "cluster_labels" {
    type = "map"
}

variable "k8s_version" {
    default = "1.13.12"
}
variable "disk_size_gb" {
    default = 60
}

variable client_id {
    type = "string"
}

variable client_secret {
    type = "string"
}

variable "ssh_public_key" {
    type = "string"
}

#variable "scf_domain" {
#    type = "string"
#}
#
variable "chart_values_file" {
    type = "string"
}

variable "stratos_metrics_config_file" {
    type = "string"
}

variable "cap_domain" {
    type = "string"
}
