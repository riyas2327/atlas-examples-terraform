provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

//
// NETWORKING
//
module "vpc" {
    source = "./vpc"
    vpc_cidr = "${var.vpc_cidr}"
    subnet_cidr = "${var.subnet_cidr}"
}
