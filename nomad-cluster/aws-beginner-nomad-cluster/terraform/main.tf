//
// Providers & Modules
//
provider "aws" {
  region = "${var.region}"
}

module "shared" {
  source = "./shared"

  key_name = "${var.atlas_environment}"
}


//
// Variables
//
variable "atlas_token"       {}
variable "atlas_username"    {}
variable "atlas_environment" { default = "nomad-cluster" }

variable "region"        { default = "us-east-1" }
variable "source_ami"    { default = "ami-9a562df2" }
variable "key_name"      { default = "atlas-example" }
variable "instance_type" { default = "t2.small" }

variable "vpc_cidr"  { default = "172.31.0.0/16" }
variable "vpc_cidrs" { default = "172.31.0.0/20,172.31.16.0/20,172.31.32.0/20" }

variable "consul_bootstrap_expect" { default = "3" }
variable "nomad_bootstrap_expect"  { default = "3" }
variable "nomad_client_nodes"      { default = "3" }

//
// Outputs
//
output "nomad_server_1" {
  value = "${aws_instance.nomad_server_1.private_ip} - ${aws_instance.nomad_server_1.public_ip}"
}

output "nomad_server_2" {
  value = "${aws_instance.nomad_server_2.private_ip} - ${aws_instance.nomad_server_2.public_ip}"
}

output "nomad_server_3" {
  value = "${aws_instance.nomad_server_3.private_ip} - ${aws_instance.nomad_server_3.public_ip}"
}

output "nomad clients" {
  value = "${join(", ", aws_instance.nomad_client.*.public_ip)}"
}
