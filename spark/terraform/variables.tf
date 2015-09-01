variable "access_key" {}

variable "secret_key" {}

variable "region" {}

variable "source_ami" {}

variable "atlas_user_token" {}

variable "atlas_username" {}

variable "atlas_environment" {}

variable "instance_type" {
	default = "t2.micro"
}

variable "consul_bootstrap_expect" {
	default = "3"
}

variable "spark_slave_count" {
	default = "3"
}

variable "vpc_cidr" {
	default = "172.31.0.0/16"
}

variable "subnet_cidr" {
	default = "172.31.0.0/20"
}
