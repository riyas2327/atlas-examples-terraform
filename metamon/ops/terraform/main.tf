variable "atlas_username" {}
variable "atlas_token" {}
variable "atlas_environment" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "availability_zone" {}
variable "source_cidr_block" {}
variable "metamon_private_key" {}
variable "metamon_public_key" {}
variable "metamon_instance_type" {}
variable "metamon_count" {}
variable "consul_private_key" {}
variable "consul_public_key" {}
variable "consul_instance_type" {}
variable "consul_server_count" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}

resource "atlas_artifact" "metamon" {
  name = "${var.atlas_username}/metamon"
  type = "amazon.ami"
}

resource "atlas_artifact" "consul" {
  name = "${var.atlas_username}/consul"
  type = "amazon.ami"
}

resource "aws_key_pair" "metamon" {
  key_name   = "metamon-key-pair"
  public_key = "${file(var.metamon_public_key)}"
}

resource "aws_key_pair" "consul" {
  key_name   = "consul-key-pair"
  public_key = "${file(var.consul_public_key)}"
}

module "network" {
  source = "./network"

  name              = "${var.atlas_environment}"
  source_cidr_block = "${var.source_cidr_block}"
  availability_zone = "${var.availability_zone}"
}

module "sg_web" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_web"

  vpc_id              = "${module.network.vpc_id}"
  aws_access_key      = "${var.aws_access_key}"
  aws_secret_key      = "${var.aws_secret_key}"
  aws_region          = "${var.region}"
  security_group_name = "${var.atlas_environment}.allow_web"
  source_cidr_block   = "0.0.0.0/0"
}

module "sg_consul" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_consul"

  vpc_id              = "${module.network.vpc_id}"
  aws_access_key      = "${var.aws_access_key}"
  aws_secret_key      = "${var.aws_secret_key}"
  aws_region          = "${var.region}"
  security_group_name = "${var.atlas_environment}.allow_consul"
  source_cidr_block   = "0.0.0.0/0"
}

resource "template_file" "consul_upstart" {
  filename = "scripts/consul_upstart.sh"

  vars {
    atlas_username      = "${var.atlas_username}"
    atlas_token         = "${var.atlas_token}"
    atlas_environment   = "${var.atlas_environment}"
    consul_server_count = "${var.consul_server_count}"
  }
}

resource "aws_instance" "metamon" {
  ami                    = "${atlas_artifact.metamon.metadata_full.region-us-east-1}"
  user_data              = "${template_file.consul_upstart.rendered}"
  key_name               = "${aws_key_pair.metamon.key_name}"
  instance_type          = "${var.metamon_instance_type}"
  availability_zone      = "${var.availability_zone}"
  count                  = "${var.metamon_count}"
  subnet_id              = "${module.network.subnet_id}"
  vpc_security_group_ids = [
    "${module.sg_web.security_group_id_web}",
    "${module.sg_consul.security_group_id}"
  ]

  tags { Name = "metamon.${count.index+1}" }
}


resource "aws_instance" "consul" {
  ami                    = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
  user_data              = "${template_file.consul_upstart.rendered}"
  key_name               = "${aws_key_pair.consul.key_name}"
  instance_type          = "${var.consul_instance_type}"
  availability_zone      = "${var.availability_zone}"
  count                  = "${var.consul_server_count}"
  subnet_id              = "${module.network.subnet_id}"
  vpc_security_group_ids = [
    "${module.sg_web.security_group_id_web}",
    "${module.sg_consul.security_group_id}"
  ]

  tags { Name = "consul.${count.index+1}" }
}
