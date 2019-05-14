data "aws_availability_zones" "available" {}

resource "aws_subnet" "main" {
  count = "${length(data.aws_availability_zones.available.names)}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.main.id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}-public-az-${count.index}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"

  depends_on = ["aws_internet_gateway.main"]
}