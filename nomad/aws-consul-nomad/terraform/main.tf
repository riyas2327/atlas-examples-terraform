//
// Providers & Modules
//
provider "aws" {}

module "shared" {
  source = "../../shared"

  os                  = "${var.os}"
  region              = "${data.aws_region.main.name}"
  atlas_token         = "NOT_USED"
  atlas_username      = "NOT_USED"
  atlas_environment   = "${var.atlas_environment}"
  consul_server_nodes = "${var.consul_server_nodes}"
  nomad_server_nodes  = "${var.nomad_server_nodes}"
}

//
// Variables
//
variable "atlas_environment" {
  default = "consul-nomad"
}

variable "os" {
  default = "ubuntu"
}

variable "key_name" {
  default = "atlas-example"
}

variable "instance_type" {
  default = "m4.large"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "vpc_cidrs" {
  default = ["172.31.0.0/20", "172.31.16.0/20", "172.31.32.0/20"]
}

variable "client_nodes" {
  default = "3"
}

variable "consul_server_nodes" {
  default = "3"
}

variable "nomad_server_nodes" {
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
output "clients" {
  value = ["${aws_instance.client.*.public_ip}"]
}

output "servers_consul" {
  value = ["${aws_instance.server_consul.*.public_ip}"]
}

output "servers_nomad" {
  value = ["${aws_instance.server_nomad.*.public_ip}"]
}

output "base_user" {
  value = ["${module.shared.base_user}"]
}

output "base_image_name" {
  value = ["${module.shared.base_image_name}"]
}
