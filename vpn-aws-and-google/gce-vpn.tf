resource "google_compute_address" "vpn" {
  name = "${var.atlas_environment}-address-vpn"
}

resource "google_compute_vpn_gateway" "vpn" {
  name    = "google-to-aws-vpn"
  network = "${google_compute_network.main.self_link}"
  region  = "${var.gce_region}"                        // needed until this is fixed - https://github.com/hashicorp/terraform/issues/5027
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name               = "google-to-aws-vpn-tunnel1"
  ike_version        = "1"
  peer_ip            = "${aws_vpn_connection.vpn.tunnel1_address}"
  shared_secret      = "${aws_vpn_connection.vpn.tunnel1_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.vpn.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr1_udp500",
    "google_compute_forwarding_rule.fr1_udp4500",
    "google_compute_forwarding_rule.fr1_esp",
  ]

  region = "${var.gce_region}" // needed until this is fixed - https://github.com/hashicorp/terraform/issues/5027
}

resource "google_compute_route" "tunnel1" {
  name                = "google-to-aws-vpn-tunnel1-route"
  network             = "${google_compute_network.main.name}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1.self_link}"
  dest_range          = "${var.aws_vpc_cidr}"
  priority            = 1000
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name               = "google-to-aws-vpn-tunnel2"
  ike_version        = "1"
  peer_ip            = "${aws_vpn_connection.vpn.tunnel2_address}"
  shared_secret      = "${aws_vpn_connection.vpn.tunnel2_preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.vpn.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr1_udp500",
    "google_compute_forwarding_rule.fr1_udp4500",
    "google_compute_forwarding_rule.fr1_esp",
  ]

  region = "${var.gce_region}" // needed until this is fixed - https://github.com/hashicorp/terraform/issues/5027
}

resource "google_compute_route" "tunnel2" {
  name                = "google-to-aws-vpn-tunnel2-route"
  network             = "${google_compute_network.main.name}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel2.self_link}"
  dest_range          = "${var.aws_vpc_cidr}"
  priority            = 1000
}

# Forward IPSec traffic coming into our static IP to our VPN gateway.
resource "google_compute_forwarding_rule" "fr1_esp" {
  name        = "fr1-esp"
  region      = "${var.gce_region}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn.address}"
  target      = "${google_compute_vpn_gateway.vpn.self_link}"
}

# The following two sets of forwarding rules are used as a part of the IPSec
# protocol
resource "google_compute_forwarding_rule" "fr1_udp500" {
  name        = "fr1-udp500"
  region      = "${var.gce_region}"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.vpn.address}"
  target      = "${google_compute_vpn_gateway.vpn.self_link}"
}

resource "google_compute_forwarding_rule" "fr1_udp4500" {
  name        = "fr1-udp4500"
  region      = "${var.gce_region}"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.vpn.address}"
  target      = "${google_compute_vpn_gateway.vpn.self_link}"
}

resource "google_compute_firewall" "vpn" {
  name          = "${var.atlas_environment}-vpn"
  network       = "${google_compute_network.main.name}"
  source_ranges = ["${var.aws_vpc_cidr}"]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}