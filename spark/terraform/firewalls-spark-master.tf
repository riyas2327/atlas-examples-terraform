//
// Master Firewall
// From: https://github.com/apache/spark/blob/v1.4.1/ec2/spark_ec2.py#L468-L527
//
resource "aws_security_group" "spark-master" {
    name = "spark-master"
    description = "Spark Master"
    vpc_id = "${module.vpc.vpc_id}"
}

// master - self firewalls

resource "aws_security_group_rule" "spark-master-icmp-self" {
    security_group_id = "${aws_security_group.spark-master.id}"
    type = "ingress"
    protocol = "icmp"
    from_port = -1
    to_port = -1
    self = true
}

resource "aws_security_group_rule" "spark-master-tcp-all-self" {
    security_group_id = "${aws_security_group.spark-master.id}"
    type = "ingress"
    protocol = "tcp"
    from_port = 0
    to_port = 65535
    self = true
}

resource "aws_security_group_rule" "spark-master-udp-all-self" {
    security_group_id = "${aws_security_group.spark-master.id}"
    type = "ingress"
    protocol = "udp"
    from_port = 0
    to_port = 65535
    self = true
}

resource "aws_security_group_rule" "spark-master-icmp-all-slave" {
    security_group_id = "${aws_security_group.spark-master.id}"
    type = "ingress"
    protocol = "icmp"
    from_port = -1
    to_port = -1
    source_security_group_id = "${aws_security_group.spark-slave.id}"
}

resource "aws_security_group_rule" "spark-master-tcp-all-slave" {
    security_group_id = "${aws_security_group.spark-master.id}"
    type = "ingress"
    protocol = "tcp"
    from_port = 0
    to_port = 65535
    source_security_group_id = "${aws_security_group.spark-slave.id}"
}

resource "aws_security_group_rule" "spark-master-udp-all-slave" {
    security_group_id = "${aws_security_group.spark-master.id}"
    type = "ingress"
    protocol = "udp"
    from_port = 0
    to_port = 65535
    source_security_group_id = "${aws_security_group.spark-slave.id}"
}
