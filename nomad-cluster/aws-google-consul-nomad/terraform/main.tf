//
// Variables
//
variable "atlas_token" {}

variable "atlas_username" {}

variable "atlas_environment" {
  default = "aws-google-consul-nomad"
}

variable "server_nodes" {
  default = "3"
}

variable "client_nodes" {
  default = "3"
}

//
// Amazon Specific
//
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_source_ami" {
  // us-east-1 - default = "ami-9a562df2"
  default = "ami-9a380b87" // eu-central-1
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
  default = "europe-west1"
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
// Nomad Specific
//
variable "nomad_region" {
  default = "global"
}

# wait for vpn connectivity for 5 minutes
variable "vpn_wait_timeout" {
  default = "300"
}

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
  source = "../../shared"

  // these are not used as long as the deprecated scripts are still in use
  region               = "not_used"
  atlas_token          = "not_used"
  atlas_username       = "not_used"
  atlas_environment    = "not_used"
}

//
// Outputs
//
output "aws_servers" {
  value = ["${aws_instance.server.*.public_ip}"]
}

output "aws_clients" {
  value = ["${aws_instance.client.*.public_ip}"]
}

output "gce_servers" {
  value = ["${google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "gce_clients" {
  value = ["${google_compute_instance.client.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "ping_aws_to_google" {
  value = "ssh -i shared/ssh_keys/atlas-examples.pem ubuntu@${aws_instance.server.0.public_ip} ping ${google_compute_instance.server.0.network_interface.0.address}"
}

output "ping_google_to_aws" {
  value = "ssh -i shared/ssh_keys/atlas-examples.pem ubuntu@${google_compute_instance.server.0.network_interface.0.access_config.0.assigned_nat_ip} ping ${aws_instance.server.0.private_ip}"
}
