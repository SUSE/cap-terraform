
# Provider Configuration
#
terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  version     = "3.11.0"
  region      = var.region
  max_retries = 15
  access_key  = var.access_key_id
  secret_key  = var.secret_access_key
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
}

provider "local" {
  version = "2.0.0"
}

provider "null" {
  version = "3.0.0"
}

provider "random" {
  version = "3.0.0"
}

