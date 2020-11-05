#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "random_string" "cluster_name" {
  length  = 8
  special = false
  upper   = false
  number  = false
}

locals {
  cluster_name = "cap-${random_string.cluster_name.result}"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "${local.cluster_name}-vpc",
    "kubernetes.io/cluster/${local.cluster_name}", "shared"
  )
}

resource "aws_subnet" "main" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.main.id

  tags = map(
    "Name", "${local.cluster_name}-public-az-${count.index}",
    "kubernetes.io/cluster/${local.cluster_name}", "shared",
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.main.*.id[count.index]
  route_table_id = aws_route_table.main.id
}
