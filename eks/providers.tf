#
# Provider Configuration
#

provider "aws" {
  version = "~> 2.0"
  region = "${var.region}"
  max_retries = 15
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
