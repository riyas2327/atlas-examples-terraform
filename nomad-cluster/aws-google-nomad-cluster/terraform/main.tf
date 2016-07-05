//
// Variables
//
variable "atlas_token" {}

variable "atlas_username" {}

variable "atlas_environment" {
  default = "hybrid-cloud"
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

variable "aws_servers" {
  default = "3"
}

variable "aws_nomad_clients" {
  default = "3"
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

variable "gce_servers" {
  default = "3"
}

variable "gce_nomad_clients" {
  default = "3"
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

  key_name = "${var.atlas_environment}"
}

//
// Outputs
//
output "info" {
  value = <<EOF

AWS servers:
    ${join("\n    ", formatlist("%s/%s - ssh -i shared/ssh_keys/${var.atlas_environment}.pem ubuntu@%s", aws_instance.server.*.private_ip, aws_instance.server.*.public_ip, aws_instance.server.*.public_ip))}

AWS clients:
    ${join("\n    ", formatlist("%s/%s - ssh -i shared/ssh_keys/${var.atlas_environment}.pem ubuntu@%s", aws_instance.nomad_client.*.private_ip, aws_instance.nomad_client.*.public_ip, aws_instance.nomad_client.*.public_ip))}

GCE servers:
    ${join("\n    ", formatlist("%s/%s - ssh -i shared/ssh_keys/${var.atlas_environment}.pem ubuntu@%s", google_compute_instance.server.*.network_interface.0.address, google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip, google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip))}

GCE clients:
    ${join("\n    ", formatlist("%s/%s - ssh -i shared/ssh_keys/${var.atlas_environment}.pem ubuntu@%s", google_compute_instance.nomad_client.*.network_interface.0.address, google_compute_instance.nomad_client.*.network_interface.0.access_config.0.assigned_nat_ip, google_compute_instance.nomad_client.*.network_interface.0.access_config.0.assigned_nat_ip))}
EOF
}

output "ping_aws_to_google" {
  value = "ssh -i shared/ssh_keys/${var.atlas_environment}.pem ubuntu@${aws_instance.server.0.public_ip} ping ${google_compute_instance.server.0.network_interface.0.address}"
}

output "ping_google_to_aws" {
  value = "ssh -i shared/ssh_keys/${var.atlas_environment}.pem ubuntu@${google_compute_instance.server.0.network_interface.0.access_config.0.assigned_nat_ip} ping ${aws_instance.server.0.private_ip}"
}
