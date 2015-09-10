variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "region_west" {}

variable "atlas_token" { }
variable "atlas_organization" {}
variable "atlas_environment" {}

//
// Instance Variables
//
variable "key_name" {}

variable "instance_type" {
	default = "t2.micro"
}

variable "consul_bootstrap_expect" {
	default = "3"
}

//
// East VPC Variables
//
variable "vpc_cidr" {
	default = "172.16.0.0/16"
}

variable "vpc_cidrs" {
	default = "172.16.0.0/20,172.16.16.0/20,172.16.32.0/20"
}

variable "subnets" {
	default = "us-east-1a,us-east-1b,us-east-1d"
}

//
// West VPC Variables
//
variable "west_vpc_cidr" {
	default = "172.17.0.0/16"
}

variable "west_vpc_cidrs" {
	default = "172.17.0.0/20,172.17.16.0/20,172.17.32.0/20"
}

variable "west_subnets" {
	default = "us-west-2a,us-west-2b,us-west-2c"
}
