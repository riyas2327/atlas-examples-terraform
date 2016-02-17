//
// Variables
//
variable "atlas_token" {
}

variable "atlas_username" {
}

variable "atlas_environment" {
  default = "hybrid-cloud"
}

//
// Amazon Specific
//
variable "aws_region" {
  default = "us-east-1"
}

variable "aws_source_ami" {
  default = "ami-9a562df2"
}

variable "aws_instance_type" {
  default = "t2.small"
}

variable "aws_vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "aws_vpc_cidrs" {
  default = "10.10.0.0/20,10.10.16.0/20,10.10.32.0/20"
}

//
// Google Specific
//
variable "gce_region" {
  default = "us-central1"
}

variable "gce_source_image" {
  default = "ubuntu-1404-trusty-v20160114e"
}

variable "gce_instance_type" {
  default = "g1-small"
}

variable "gce_vpc_cidr" {
  default = "10.11.0.0/16"
}

variable "gce_vpc_cidrs" {
  default = "10.11.0.0/20,10.11.16.0/20,10.11.32.0/20"
}

//
// Amazon Specific
//
variable "consul_bootstrap_expect" { default = "3" }
variable "nomad_bootstrap_expect"  { default = "3" }
variable "nomad_client_nodes"      { default = "3" }
variable "nomad_region"            { default = "global" }

# wait for vpn connectivity for 5 minutes
variable "vpn_wait_timeout"        { default = "300" }

//
// Providers & Modules
//
provider "aws" {
  region = "${var.aws_region}"
}

provider "google" {
  region = "${var.gce_region}"
}

module "shared" {
  source = "./shared"

  key_name = "${var.atlas_environment}"
}

//
// Outputs
//
output "aws_nomad_servers_public" {
  value = "${aws_instance.nomad_server_1.public_ip}, ${aws_instance.nomad_server_2.public_ip}, ${aws_instance.nomad_server_3.public_ip}"
}

output "aws_nomad_servers_private" {
  value = "${aws_instance.nomad_server_1.private_ip}, ${aws_instance.nomad_server_2.private_ip}, ${aws_instance.nomad_server_3.private_ip}"
}

output "aws_nomad_clients_public" {
  value = "${join(", ", aws_instance.nomad_client.*.public_ip)}"
}

output "aws_nomad_clients_private" {
  value = "${join(", ", aws_instance.nomad_client.*.private_ip)}"
}

output "gce_nomad_servers_public" {
  value = "${google_compute_instance.nomad_server_1.network_interface.0.access_config.0.assigned_nat_ip}, ${google_compute_instance.nomad_server_2.network_interface.0.access_config.0.assigned_nat_ip}, ${google_compute_instance.nomad_server_3.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "gce_nomad_servers_private" {
  value = "${google_compute_instance.nomad_server_1.network_interface.0.address}, ${google_compute_instance.nomad_server_2.network_interface.0.address}, ${google_compute_instance.nomad_server_3.network_interface.0.address}"
}

output "gce_nomad_clients_public" {
  value = "${join(", ", google_compute_instance.nomad_client.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}

output "gce_nomad_clients_private" {
  value = "${join(", ", google_compute_instance.nomad_client.*.network_interface.0.address)}"
}

output "ping_aws_to_google" {
  value = "ssh -i shared/ssh_keys/hybrid-cloud.pem ${aws_instance.nomad_server_1.public_ip} ping ${google_compute_instance.nomad_server_1.network_interface.0.address}"
}

output "ping_google_to_aws" {
  value = "ssh -i shared/ssh_keys/hybrid-cloud.pem ${google_compute_instance.nomad_server_1.network_interface.0.access_config.0.assigned_nat_ip} ping ${aws_instance.nomad_server_1.private_ip}"
}
