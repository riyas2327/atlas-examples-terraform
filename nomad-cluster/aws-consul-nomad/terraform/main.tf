//
// Providers & Modules
//
provider "aws" {
}

module "shared" {
  source = "../../shared"

  region               = "${data.aws_region.main.name}"
  atlas_token          = "${var.atlas_token}"
  atlas_username       = "${var.atlas_username}"
  atlas_environment    = "${var.atlas_environment}"
  server_nodes         = "${var.server_nodes}"
}

//
// Variables
//
variable "atlas_token" {}

variable "atlas_username" {}

variable "atlas_environment" {
  default = "consul-nomad"
}

variable "source_ami" {
  default = "ami-9a562df2"
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
  default = ["172.31.0.0/20","172.31.16.0/20","172.31.32.0/20"]
}

variable "server_nodes" {
  default = "3"
}

variable "client_nodes" {
  default = "3"
}

//
// Data Sources
//
data "aws_region" "main" {
  current = true
}

data "aws_availability_zones" "main" {}

data "aws_ami" "ubuntu_trusty" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

//
// Outputs
//
output "servers" {
  value = ["${aws_instance.server.*.public_ip}"]
}

output "clients" {
  value = ["${aws_instance.client.*.public_ip}"]
}
