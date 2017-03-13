//
// Required Variables
//
variable "vpc_id" {
  type = "string"
}

variable "subnet_private_ids" {
  type = "list"
}

variable "bastion_ips" {
  type = "list"
}

variable "bastion_user" {
  type = "string"
}

//
// Variables w/ Defaults
//
variable "os" {
  default = "ubuntu"
}

variable "environment_name" {
  default = "consul-vault"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "client_nodes" {
  default = "3"
}

variable "consul_server_nodes" {
  default = "3"
}

variable "vault_server_nodes" {
  default = "3"
}

//
// Outputs
//
output "servers_consul" {
  value = ["${aws_instance.server_consul.*.private_ip}"]
}

output "servers_vault" {
  value = ["${aws_instance.server_vault.*.private_ip}"]
}

output "base_user" {
  value = "${module.shared.base_user}"
}
