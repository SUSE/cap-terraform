#
# Provider Configuration
#

provider "aws" {
  version = "~> 2.0"
  region = var.region
  max_retries = 15
  
  assume_role {
  //  role_arn     = "arn:aws:iam::138384977974:role/eksServiceRole"
  role_arn         = var.assume_role_arn
    
  }


}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
