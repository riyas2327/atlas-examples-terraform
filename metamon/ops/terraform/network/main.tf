variable "name" {}
variable "source_cidr_block" {}
variable "availability_zone" {}

resource "aws_vpc" "mod" {
  cidr_block = "${var.source_cidr_block}/16"
  enable_dns_hostnames = true

  tags { Name = "${var.name}" }
}

resource "aws_subnet" "mod" {
  vpc_id = "${aws_vpc.mod.id}"
  cidr_block = "${var.source_cidr_block}/20"
  availability_zone = "${var.availability_zone}"
  map_public_ip_on_launch = true

  tags { Name = "${var.name}" }
}

resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"

  tags { Name = "${var.name}" }
}

resource "aws_route_table" "mod" {
  vpc_id = "${aws_vpc.mod.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mod.id}"
  }
  tags { Name = "${var.name}" }
}

resource "aws_main_route_table_association" "mod" {
  vpc_id = "${aws_vpc.mod.id}"
  route_table_id = "${aws_route_table.mod.id}"
}

output "vpc_id" { value = "${aws_vpc.mod.id}" }
output "subnet_id" { value = "${aws_subnet.mod.id}" }
