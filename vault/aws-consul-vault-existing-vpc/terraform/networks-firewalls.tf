//
// Default Egress
//
resource "aws_security_group" "egress" {
  name        = "${var.environment_name}-egress_internal"
  description = "${var.environment_name}-egress_internal"
  vpc_id      = "${data.aws_vpc.main.id}"
}

resource "aws_security_group_rule" "egress_internal" {
  security_group_id = "${aws_security_group.egress.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["${data.aws_vpc.main.cidr_block}"]
}

resource "aws_security_group_rule" "egress_external" {
  security_group_id = "${aws_security_group.egress.id}"
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
  name        = "${var.environment_name}-admin_access"
  description = "${var.environment_name}-admin_access"
  vpc_id      = "${data.aws_vpc.main.id}"
}

resource "aws_security_group_rule" "admin_ssh" {
  security_group_id = "${aws_security_group.admin_access.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${data.aws_vpc.main.cidr_block}"]
}

//
// All
// - all ports open to other instances
// - TODO: Restrict specific ports
//
resource "aws_security_group" "vault_all" {
  name        = "${var.environment_name}-vault_all"
  description = "${var.environment_name}-vault_all"
  vpc_id      = "${data.aws_vpc.main.id}"
}

resource "aws_security_group_rule" "all_tcp_self" {
  security_group_id = "${aws_security_group.vault_all.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 1
  to_port           = 65535
  self              = true
}

resource "aws_security_group_rule" "all_udp_self" {
  security_group_id = "${aws_security_group.vault_all.id}"
  type              = "ingress"
  protocol          = "udp"
  from_port         = 1
  to_port           = 65535
  self              = true
}
