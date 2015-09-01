//
// Slave Firewall
// From: https://github.com/apache/spark/blob/v1.4.1/ec2/spark_ec2.py#L504-L526
//
resource "aws_security_group" "spark-slave" {
    name = "spark-slave"
    description = "Spark Slave"
    vpc_id = "${module.vpc.vpc_id}"
}

// slave - self firewalls

resource "aws_security_group_rule" "spark-slave-icmp-self" {
    security_group_id = "${aws_security_group.spark-slave.id}"
    type = "ingress"
    protocol = "icmp"
    from_port = -1
    to_port = -1
    self = true
}

resource "aws_security_group_rule" "spark-slave-tcp-all-self" {
    security_group_id = "${aws_security_group.spark-slave.id}"
    type = "ingress"
    protocol = "tcp"
    from_port = 0
    to_port = 65535
    self = true
}

resource "aws_security_group_rule" "spark-slave-udp-all-self" {
    security_group_id = "${aws_security_group.spark-slave.id}"
    type = "ingress"
    protocol = "udp"
    from_port = 0
    to_port = 65535
    self = true
}

resource "aws_security_group_rule" "spark-slave-icmp-all-master" {
    security_group_id = "${aws_security_group.spark-slave.id}"
    type = "ingress"
    protocol = "icmp"
    from_port = -1
    to_port = -1
    source_security_group_id = "${aws_security_group.spark-master.id}"
}

resource "aws_security_group_rule" "spark-slave-tcp-all-master" {
    security_group_id = "${aws_security_group.spark-slave.id}"
    type = "ingress"
    protocol = "tcp"
    from_port = 0
    to_port = 65535
    source_security_group_id = "${aws_security_group.spark-master.id}"
}

resource "aws_security_group_rule" "spark-slave-udp-all-master" {
    security_group_id = "${aws_security_group.spark-slave.id}"
    type = "ingress"
    protocol = "udp"
    from_port = 0
    to_port = 65535
    source_security_group_id = "${aws_security_group.spark-master.id}"
}
