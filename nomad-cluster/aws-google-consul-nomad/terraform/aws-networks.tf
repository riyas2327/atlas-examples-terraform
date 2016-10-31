resource "aws_vpc" "main" {
  cidr_block           = "${var.aws_vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.atlas_environment}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.atlas_environment}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  route {
    cidr_block = "${var.gce_vpc_cidr}"
    gateway_id = "${aws_vpn_gateway.vpn.id}"
  }

  propagating_vgws = [
    "${aws_vpn_gateway.vpn.id}",
  ]

  tags {
    Name = "${var.atlas_environment}"
  }
}

resource "aws_route_table_association" "main" {
    subnet_id      = "${aws_subnet.subnet_a.id}"
    route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(split(",",var.aws_vpc_cidrs),0)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.atlas_environment}"
  }
}
