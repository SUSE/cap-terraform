variable "cluster_labels" {
    description = "Tags to be applied to resources in your cluster. (Optional)"
    type = map
  }
  
  variable "disk_size_gb" {
    default = 80
    description = "The worker node storage capacity. (Minimum:80, Maximum: 65536)"
    type = number
  }
  
  variable "dns_credentials_json" {
    description = "Contents of a service account key file in JSON format, with rights to edit DNS."
    type = string
  }
  
  variable "instance_count" {
    default = 3
    description = "The number of worker nodes in your cluster. (Minimum: 3, Maximum 50)"
    type = number
  }
  
  variable "instance_type" {
    default = "n1-standard-4"
    description = "The type of instance used for the provisioned workers."
    type = string
  }
  
  variable "k8s_version" {
    description = "k8s version"
    type = string
  }
  
  variable "location" {
    description = "The GCP region where the cluster is placed, including the zone."
    type = string
  }
