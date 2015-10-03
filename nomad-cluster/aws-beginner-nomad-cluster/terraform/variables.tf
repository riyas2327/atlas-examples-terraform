variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}

variable "atlas_token" { }
variable "atlas_organization" {}
variable "atlas_environment" {}

//
// Instance Variables
//
variable "source_ami" {
  default = "ami-9a562df2"
}
variable "key_name" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "nomad_bootstrap_expect" {
  default = "3"
}

//
// VPC Variables
//
variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "vpc_cidrs" {
  default = "172.31.0.0/20,172.31.16.0/20,172.31.32.0/20"
}
