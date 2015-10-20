variable "name" { default = "haproxy" }
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "user_data" {}
variable "amis" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_ids" {}

resource "aws_security_group" "haproxy" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "HAProxy security group"

  tags { Name = "${var.name}" }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "template_file" "user_data" {
  filename = "${var.user_data}"

  vars {
    atlas_username    = "${var.atlas_username}"
    atlas_environment = "${var.atlas_environment}"
    atlas_token       = "${var.atlas_token}"
    node_name         = "${var.name}"
    service           = "${var.name}"
  }
}

resource "aws_instance" "haproxy" {
  ami           = "${element(split(",", var.amis), count.index)}"
  count         = "${length(split(",", var.amis))}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(split(",", var.subnet_ids), count.index)}"
  user_data     = "${element(template_file.user_data.*.rendered, count.index)}"

  vpc_security_group_ids = ["${aws_security_group.haproxy.id}"]

  tags { Name = "${var.name}" }
}

output "ip" { value = "${aws_instance.haproxy.public_ip}" }
