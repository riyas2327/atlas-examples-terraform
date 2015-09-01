resource "aws_security_group" "admin-access" {
    name = "admin-access"
    description = "Admin Access"
    vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "admin-ssh" {
    security_group_id = "${aws_security_group.admin-access.id}"
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "admin-egress" {
    security_group_id = "${aws_security_group.admin-access.id}"
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
}
