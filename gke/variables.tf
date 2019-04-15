variable "location" {
    default = "us-central1-a"
}

variable "project" {
    default = "suse-css-platform"
}

variable "node_pool_name" {
    type = "string"
}

variable "node_count" {
    default = "3"
}
variable "machine_type" {
    default = "n1-standard-4"
}

variable "disk_size_gb" {
    default = 60
}

variable "gke_sa_key" {
    type = "string"
}




