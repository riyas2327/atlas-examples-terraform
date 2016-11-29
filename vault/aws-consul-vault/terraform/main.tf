//
// Providers & Modules
//
provider "aws" {}

module "shared" {
  source = "../../shared"

  os                  = "${var.os}"
  region              = "${data.aws_region.main.name}"
  atlas_token         = "${var.atlas_token}"
  atlas_username      = "${var.atlas_username}"
  atlas_environment   = "${var.atlas_environment}"
  consul_server_nodes = "${var.consul_server_nodes}"
}

//
// Variables
//
variable "atlas_token" {}

variable "atlas_username" {}

variable "atlas_environment" {
  default = "consul-vault"
}

variable "os" {
  default = "ubuntu"
}

variable "key_name" {
  default = "atlas-example"
}

variable "instance_type" {
  default = "t2.small"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "vpc_cidrs" {
  default = [
    "172.31.0.0/20",
    "172.31.16.0/20",
    "172.31.32.0/20",
  ]
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
// Data Sources
//
data "aws_region" "main" {
  current = true
}

data "aws_availability_zones" "main" {}

//
// Outputs
//
output "servers_consul" {
  value = ["${aws_instance.server_consul.*.public_ip}"]
}

output "servers_vault" {
  value = ["${aws_instance.server_vault.*.public_ip}"]
}

output "base_user" {
  value = ["${module.shared.base_user}"]
}

output "base_image_name" {
  value = ["${module.shared.base_image_name}"]
}
