resource "aws_customer_gateway" "vpn" {
  bgp_asn    = 60000
  ip_address = "${google_compute_address.vpn.address}"
  type       = "ipsec.1"

  tags {
    Name = "${var.atlas_environment}"
  }
}

resource "aws_vpn_gateway" "vpn" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "aws-to-google-vpn"
  }
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn.id}"
  customer_gateway_id = "${aws_customer_gateway.vpn.id}"
  type                = "ipsec.1"
  static_routes_only  = true

  tags {
    Name = "aws-to-google-vpn"
  }
}

resource "aws_vpn_connection_route" "vpn" {
  destination_cidr_block = "${var.gce_vpc_cidr}"
  vpn_connection_id      = "${aws_vpn_connection.vpn.id}"
}