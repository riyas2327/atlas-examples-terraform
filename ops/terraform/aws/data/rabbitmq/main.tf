variable "name" { default = "rabbitmq" }
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "amis" {}
variable "instance_type" {}
variable "count" {}
variable "subnet_ids" {}
variable "key_name" {}
variable "key_path" {}
variable "bastion_host" {}
variable "bastion_user" {}

variable "consul_client_user_data" {}
variable "atlas_username" {}
variable "atlas_environment" {}
variable "atlas_token" {}

variable "username" {}
variable "password" {}
variable "vhost" {}

resource "aws_security_group" "rabbitmq" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for RabbitMQ"

  tags { Name = "${var.name}" }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "template_file" "consul_user_data" {
  filename = "${var.consul_client_user_data}"
  count    = "${var.count}"

  vars {
    atlas_username      = "${var.atlas_username}"
    atlas_environment   = "${var.atlas_environment}"
    atlas_token         = "${var.atlas_token}"
    node_name           = "${var.name}.${count.index+1}"
    service             = "${var.name}"
  }
}

resource "aws_instance" "rabbitmq" {
  ami           = "${element(split(",", var.amis), count.index)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(split(",", var.subnet_ids), count.index)}"
  count         = "${var.count}"
  user_data     = "${element(template_file.consul_user_data.*.rendered, count.index)}"

  vpc_security_group_ids = ["${aws_security_group.rabbitmq.id}"]

  tags { Name = "${var.name}" }

  provisioner "remote-exec" {
    connection {
      user         = "ubuntu"
      host         = "${self.private_ip}"
      key_file     = "${var.key_path}"
      bastion_host = "${var.bastion_host}"
      bastion_user = "${var.bastion_user}"
    }

    inline = [
      "sleep 20",
      "sudo rabbitmqctl add_user '${var.username}' '${var.password}'",
      "sudo rabbitmqctl add_vhost ${var.vhost}",
      "sudo rabbitmqctl set_permissions -p '${var.vhost}' '${var.username}' '.*' '.*' '.*'",
      "sudo rabbitmqctl set_user_tags '${var.username}' administrator",
    ]
  }
}

output "remote_commands" {
  value = <<COMMANDS
  setkey() { curl -X PUT 127.0.0.1:8500/v1/kv/service/rabbitmq/$1 -d "$2"; }
  setkey username '${var.username}'
  setkey password '${var.password}'
  setkey vhost '${var.vhost}'
COMMANDS
}

output "host"        { value = "rabbitmq.service.consul" }
output "private_ips" { value = "${join(",", aws_instance.rabbitmq.*.private_ip)}" }
output "port"        { value = "5672" }
output "username"    { value = "${var.username}" }
output "password"    { value = "${var.password}" }
output "vhost"       { value = "${var.vhost}" }
