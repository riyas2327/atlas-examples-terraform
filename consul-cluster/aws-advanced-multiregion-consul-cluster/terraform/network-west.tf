resource "aws_vpc" "west_main" {
  provider             = "aws.west"
  cidr_block           = "${var.west_vpc_cidr}"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "west_main" {
  provider = "aws.west"
  vpc_id   = "${aws_vpc.west_main.id}"
}

resource "aws_route_table" "west_main" {
  provider = "aws.west"
  vpc_id   = "${aws_vpc.west_main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.west_main.id}"
  }
}

resource "aws_main_route_table_association" "west_main" {
  provider       = "aws.west"
  vpc_id         = "${aws_vpc.west_main.id}"
  route_table_id = "${aws_route_table.west_main.id}"
}

resource "aws_subnet" "west_subnet_a" {
  provider                = "aws.west"
  vpc_id                  = "${aws_vpc.west_main.id}"
  availability_zone       = "${element(split(",",var.west_subnets),0)}"
  cidr_block              = "${element(split(",",var.west_vpc_cidrs),0)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "west_subnet_b" {
  provider                = "aws.west"
  vpc_id                  = "${aws_vpc.west_main.id}"
  availability_zone       = "${element(split(",",var.west_subnets),1)}"
  cidr_block              = "${element(split(",",var.west_vpc_cidrs),1)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "west_subnet_c" {
  provider                = "aws.west"
  vpc_id                  = "${aws_vpc.west_main.id}"
  availability_zone       = "${element(split(",",var.west_subnets),2)}"
  cidr_block              = "${element(split(",",var.west_vpc_cidrs),2)}"
  map_public_ip_on_launch = true
}
