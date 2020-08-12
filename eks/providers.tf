#
# Provider Configuration
#

locals {
    operator_role = var.deployer_role_arn == "" ? {} : {
         deployer = var.deployer_role_arn
    }
}

provider "aws" {
  version = "~> 3.1.0"
  region = var.region
  max_retries = 15

  dynamic "assume_role" {
    for_each = local.operator_role
        content {
            role_arn = assume_role.value
        }  
  }  
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
