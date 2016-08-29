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
variable "atlas_environment" { default = "consul-cluster-existing" }

variable "region"           { default = "us-east-1" }
variable "source_ami"       { default = "ami-9a562df2" }
variable "instance_type"    { default = "t2.micro" }
variable "key_name"         { default = "atlas-example2" }
variable "key_data_public"  {}
variable "key_data_private" {}

variable "vpc_id"     { description = "The ID of the VPC to deploy into - used for creating security groups."}
variable "subnet_ids" {
  description = "List of subnet IDs in the form [\"subnet-abc123\",\"subnet-def456\"]."
  type = "list"
}

variable "consul_bootstrap_expect" { default = "3" }

//
// Outputs
//
output "consul_client" {
  value = "${aws_instance.consul_client.public_ip}"
}

output "consul_0" {
  value = "${aws_instance.consul_0.public_ip}"
}

output "consul_1" {
  value = "${aws_instance.consul_1.public_ip}"
}

output "consul_2" {
  value = "${aws_instance.consul_2.public_ip}"
}
