resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = "${aws_subnet.subnet_a.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = "${aws_subnet.subnet_b.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "subnet_c" {
  subnet_id      = "${aws_subnet.subnet_c.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),0)}"
  map_public_ip_on_launch = false

  tags {
    Name = "subnet_a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),1)}"
  map_public_ip_on_launch = false

  tags {
    Name = "subnet_b"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),2)}"
  map_public_ip_on_launch = false

  tags {
    Name = "subnet_c"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(split(",",var.vpc_cidrs),3)}"
  map_public_ip_on_launch = true

  tags {
    Name = "public"
  }
}
