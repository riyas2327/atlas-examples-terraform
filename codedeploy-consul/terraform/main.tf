//
// Providers & Modules
//
provider "aws" {
  region = "${var.region}"
}

module "shared" {
  source   = "../shared"
  key_name = "${var.key_name}"
}

//
// Variables
//
variable "atlas_token"       {}
variable "atlas_username"    {}
variable "atlas_environment" { default = "codedeploy" }

variable "codedeploy_s3_bucket" { default = "YOUR_BUCKET" }
variable "codedeploy_s3_path"   { default = "YOUR_PATH" }

variable "region"        { default = "us-east-1" }
variable "source_ami"    { default = "ami-9a562df2" }
variable "key_name"      { default = "codedeploy-consul" }
variable "instance_type" { default = "t2.micro" }

variable "zone_a" { default = "us-east-1a" }
variable "zone_b" { default = "us-east-1b" }
variable "zone_c" { default = "us-east-1c" }

variable "vpc_cidr"  { default = "172.31.0.0/16" }
variable "vpc_cidrs" { default = "172.31.0.0/20,172.31.16.0/20,172.31.32.0/20" }

variable "consul_bootstrap_expect" { default = "3" }
variable "consul_ui_access_cidr"   { default = "172.31.0.0/16" }

//
// Outputs
//
output "instructions" {
  value = <<OUTPUT

CodeDeploy ELB:          ${aws_elb.codedeploy.dns_name}
CodeDeploy Instances:    ${join(", ",aws_instance.codedeploy.*.public_ip)}
Consul Server Instances: ${aws_instance.consul_0.public_ip}, ${aws_instance.consul_1.public_ip}, ${aws_instance.consul_2.public_ip}

CodeDeploy Deployment Group Name: ${aws_codedeploy_deployment_group.sampleapp.deployment_group_name}

To deploy a new version of the application:
  1) aws deploy push --application-name SampleApp_Linux_Consul --s3-location s3://${var.codedeploy_s3_bucket}/${var.codedeploy_s3_path}/SampleApp_Linux_Consul.zip --source applications/SampleApp_Linux_Consul/
  2) Follow the instructions in the output from the push command or use the AWS console.

Happy deploying!
OUTPUT
}
