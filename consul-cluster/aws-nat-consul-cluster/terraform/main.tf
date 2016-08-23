//
// Providers & Modules
//
provider "aws" {
  region = "${var.region}"
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
variable "source_ami"       { default = "ami-9a562df2" }
variable "nat_ami"          { default = "ami-b0210ed8" }
variable "instance_type"    { default = "t2.micro" }
variable "key_name"         { default = "atlas-example" }
variable "key_data_public"  {}
variable "key_data_private" {}

variable "vpc_cidr"  { default = "172.31.0.0/16" }
variable "vpc_cidrs" { default = ["172.31.0.0/20","172.31.16.0/20","172.31.32.0/20","172.31.48.0/20"] }

variable "consul_bootstrap_expect" { default = "3" }

//
// Outputs
//
output "consul_client" {
  value = "${aws_instance.consul_client.private_ip}"
}

output "consul_0" {
  value = "${aws_instance.consul_0.private_ip}"
}

output "consul_1" {
  value = "${aws_instance.consul_1.private_ip}"
}

output "consul_2" {
  value = "${aws_instance.consul_2.private_ip}"
}

output "nat" {
  value = "${aws_instance.nat.public_ip}"
}
