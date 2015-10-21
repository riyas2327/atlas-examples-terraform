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

module "vpc" {
    source = "./vpc"
    vpc_cidr = "${var.vpc_cidr}"
    subnet_cidr = "${var.subnet_cidr}"
}

//
// Variables
//
variable "atlas_token"       {}
variable "atlas_username"    {}
variable "atlas_environment" { default = "spark-cluster" }

variable "region"        { default = "us-east-1" }
variable "key_name"      { default = "atlas-example" }
variable "instance_type" { default = "t2.micro" }

variable "vpc_cidr"    { default = "172.31.0.0/16" }
variable "subnet_cidr" { default = "172.31.0.0/20" }

variable "consul_bootstrap_expect" { default = "3" }
variable "spark_slave_count"       { default = "3" }

//
// Outputs
//
output "spark-example-application" {
  value = <<SPARKEXAMPLE

spark-master-0-address = ${aws_instance.spark-master.0.public_ip}
spark-slave-0-address  = ${aws_instance.spark-slave.0.public_ip}

To view the Spark console, run the command below and then open http://localhost:8080/ in your browser.

    ssh -i shared/ssh_keys/atlas-example.pem -L 8080:${aws_instance.spark-master.0.private_ip}:8080 ubuntu@${aws_instance.spark-master.0.public_ip}

To run an example Spark application in your Spark cluster, run the command below.

    ssh -i shared/ssh_keys/atlas-example.pem ubuntu@${aws_instance.spark-master.0.public_ip} MASTER=spark://${element(split(".",aws_instance.spark-master.0.private_dns),0)}:7077 /opt/spark/default/bin/run-example SparkPi 10

SPARKEXAMPLE
}
