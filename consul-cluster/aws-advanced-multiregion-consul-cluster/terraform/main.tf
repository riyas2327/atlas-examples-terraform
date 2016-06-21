//
// Providers & Modules
//
provider "aws" {
  alias      = "east"
  region     = "${var.region}"
}

provider "aws" {
  alias      = "west"
  region     = "${var.region_west}"
}

module "shared" {
  source   = "../../shared"
}

//
// Variables
//
variable "atlas_token"       {}
variable "atlas_username"    {}
variable "atlas_environment" { default = "consul-cluster" }

variable "region"           { default = "us-east-1" }
variable "region_west"      { default = "us-west-2" }
variable "source_ami"       { default = "ami-9a562df2" }
variable "instance_type"    { default = "t2.micro" }
variable "key_name"         { default = "atlas-example" }
variable "key_data_public"  {}
variable "key_data_private" {}

variable "vpc_cidr"  { default = "172.31.0.0/16" }
variable "vpc_cidrs" { default = "172.31.0.0/20,172.31.16.0/20,172.31.32.0/20,172.31.48.0/20" }

variable "west_vpc_cidr"  { default = "172.17.0.0/16" }
variable "west_vpc_cidrs" { default = "172.17.0.0/20,172.17.16.0/20,172.17.32.0/20,172.17.48.0/20" }

variable "consul_bootstrap_expect" { default = "3" }

//
// Outputs
//
output "consul_client" {
  value = "${aws_instance.consul_client.private_ip} - ${aws_instance.consul_client.public_ip}"
}

output "consul_0" {
  value = "${aws_instance.consul_0.private_ip} - ${aws_instance.consul_0.public_ip}"
}

output "consul_1" {
  value = "${aws_instance.consul_1.private_ip} - ${aws_instance.consul_1.public_ip}"
}

output "consul_2" {
  value = "${aws_instance.consul_2.private_ip} - ${aws_instance.consul_2.public_ip}"
}

output "west_consul_client" {
  value = "${aws_instance.west_consul_client.private_ip} - ${aws_instance.west_consul_client.public_ip}"
}

output "west_consul_0" {
  value = "${aws_instance.west_consul_0.private_ip} - ${aws_instance.west_consul_0.public_ip}"
}

output "west_consul_1" {
  value = "${aws_instance.west_consul_1.private_ip} - ${aws_instance.west_consul_1.public_ip}"
}

output "west_consul_2" {
  value = "${aws_instance.west_consul_2.private_ip} - ${aws_instance.west_consul_2.public_ip}"
}
