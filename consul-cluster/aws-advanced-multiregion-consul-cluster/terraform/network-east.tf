resource "aws_vpc" "main" {
  provider             = "aws.east"
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  provider = "aws.east"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  provider = "aws.east"
  vpc_id   = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_main_route_table_association" "main" {
  provider       = "aws.east"
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "subnet_a" {
  provider                = "aws.east"
  vpc_id                  = "${aws_vpc.main.id}"
  availability_zone       = "${element(split(",",var.subnets),0)}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),0)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
  provider                = "aws.east"
  vpc_id                  = "${aws_vpc.main.id}"
  availability_zone       = "${element(split(",",var.subnets),1)}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),1)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_c" {
  provider                = "aws.east"
  vpc_id                  = "${aws_vpc.main.id}"
  availability_zone       = "${element(split(",",var.subnets),2)}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),2)}"
  map_public_ip_on_launch = true
}
