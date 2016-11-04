//
// Default Egress
//
resource "aws_security_group" "default_egress" {
  name        = "default_egress"
  description = "Default Egress"
  vpc_id      = "${aws_vpc.main.id}"

  // Ensure the route table association happens before
  // SGs are created and therefore before instances.
  depends_on = ["aws_route_table_association.main"]
}

resource "aws_security_group_rule" "default_egress" {
  security_group_id = "${aws_security_group.default_egress.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

//
// Administrative Access
//
resource "aws_security_group" "admin_access" {
  name        = "admin_access"
  description = "Admin Access"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "admin_ssh" {
  security_group_id = "${aws_security_group.admin_access.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

//
// Internal Access
//
resource "aws_security_group" "internal_access" {
  name        = "internal_access"
  description = "Internal Access"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "internal_access_ping" {
  security_group_id = "${aws_security_group.internal_access.id}"
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["${var.aws_vpc_cidr}", "${var.gce_vpc_cidr}"]
}

resource "aws_security_group_rule" "internal_access_tcp" {
  security_group_id = "${aws_security_group.internal_access.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["${var.aws_vpc_cidr}", "${var.gce_vpc_cidr}"]
}

resource "aws_security_group_rule" "internal_access_udp" {
  security_group_id = "${aws_security_group.internal_access.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["${var.aws_vpc_cidr}", "${var.gce_vpc_cidr}"]
}
