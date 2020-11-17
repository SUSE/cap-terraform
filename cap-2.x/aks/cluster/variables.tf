variable "admin_password" {
    description = "Intial password for Cloud Foundry 'admin' user, UAA 'admin' OAuth client, and metrics 'admin' login. We recommend changing this password after deployment. See https://documentation.suse.com/suse-cap/single-html/cap-guides/#cha-cap-manage-passwords"
    type = string
  }
  
  variable "client_id" {
    description = "Azure Service Principal 'appId'"
    type = string
  }
  
  variable "client_secret" {
    description = "Azure Service Principal 'password'"
    type = string
  }
  
  variable "cluster_labels" {
    description = "Tags to be applied to resources in your cluster. (Optional)"
    type = map
  }
  
  variable "disk_size_gb" {
    default = 80
    description = "The worker node storage capacity. (Minimum:80, Maximum: 4095)"
    type = number
  }
  
  variable "dns_prefix" {
    default = "cap-on-aks"
    description = "Prefix for node DNS hostnames. (Must be alphanumeric, may include but not end with dashes)"
    type = string
  }
  
  variable "dns_zone_name" {
    description = "Name of the Azure DNS Zone created for the cluster."
    type = string
  }
  
  variable "dns_zone_resource_group" {
    description = "An existing Azure Resource Group where your Azure DNS Zone is hosted."
    type = string
  }
  
  variable "email" {
    description = "Email address to send TLS certificate notifications to."
    type = string
  }
  
  variable "instance_count" {
    default = 3
    description = "The number of worker nodes in your cluster. (Minimum: 3, Maximum 50)"
    type = number
  }
  
  variable "instance_type" {
    default = "Standard_DS3_v2"
    description = "The type of instance used for the provisioned workers."
    type = string
  }
  
  variable "k8s_version" {
    description = "Kubernetes version to apply to AKS; must be supported in the selected region. (Run `az aks get-versions --location $REGION --output table` for a list of supported options)"
    type = string
  }
  
  variable "location" {
    description = "The Azure region where the Resource Group is placed."
    type = string
  }
  
  variable "resource_group" {
    description = "An existing Azure Resource Group where resources will be created."
    type = string
  }
  
  variable "ssh_public_key" {
    description = "SSH public key for access to worker nodes."
    type = string
  }
  
  variable "ssh_username" {
    description = "SSH username for accessing the cluster."
    type = string
  }
  
  variable "subscription_id" {
    description = "Azure subscription ID"
    type = string
  }
  
  variable "tenant_id" {
    description = "Azure Service Principal 'tenant'"
    type = string
  }
