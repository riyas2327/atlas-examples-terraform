//
// Providers & Modules
//
provider "aws" {
  region = "${var.region}"
}

module "shared" {
  source = "../../shared"

  key_name = "${var.atlas_environment}"
}

//
// Variables
//
variable "atlas_token" {}

variable "atlas_username" {}

variable "atlas_environment" {
  default = "nomad-consul-vault-cluster"
}

variable "region" {
  default = "us-east-1"
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
