#
# Provider Configuration
#

provider "aws" {
  version     = "~> 2.0"
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
