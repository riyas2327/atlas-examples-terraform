provider "atlas" {
    token = "${var.atlas_token}"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "atlas_artifact" "metamon" {
    name = "${var.atlas_username}/metamon"
    type = "aws.ami"
}

resource "atlas_artifact" "consul" {
    name = "${var.atlas_username}/consul"
    type = "aws.ami"
}

resource "aws_vpc" "main" {
    cidr_block = "${var.source_cidr_block}/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${var.source_cidr_block}/20"
    availability_zone = "${var.availability_zone}"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "r" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}

resource "aws_main_route_table_association" "a" {
    vpc_id = "${aws_vpc.main.id}"
    route_table_id = "${aws_route_table.r.id}"
}

resource "aws_key_pair" "metamon" {
    key_name = "metamon-key-pair"
    public_key = "${file(var.metamon_public_key)}"
}

resource "aws_key_pair" "consul" {
    key_name = "consul-key-pair"
    public_key = "${file(var.consul_public_key)}"
}

module "sg_web" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_web"
  security_group_name = "allow_web"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.region}"
  vpc_id = "${aws_vpc.main.id}"
  source_cidr_block = "0.0.0.0/0"
}

module "sg_consul" {
  source = "github.com/terraform-community-modules/tf_aws_sg//sg_consul"
  security_group_name = "allow_consul"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "${var.region}"
  vpc_id = "${aws_vpc.main.id}"
  source_cidr_block = "0.0.0.0/0"
}

module "metamon" {
    source = "./metamon"
    ami = "${atlas_artifact.metamon.metadata_full.region-us-east-1}"
    subnet_id = "${aws_subnet.main.id}"
    sg_web = "${module.sg_web.security_group_id_web}"
    sg_consul = "${module.sg_consul.security_group_id}"
    key_name = "${aws_key_pair.metamon.key_name}"
    instance_type = "${var.metamon_instance_type}"
    availability_zone = "${var.availability_zone}"
    count = "${var.metamon_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.metamon_private_key}"
}

module "consul" {
    source = "./consul"
    ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
    subnet_id = "${aws_subnet.main.id}"
    sg_web = "${module.sg_web.security_group_id_web}"
    sg_consul = "${module.sg_consul.security_group_id}"
    key_name = "${aws_key_pair.consul.key_name}"
    instance_type = "${var.consul_instance_type}"
    availability_zone = "${var.availability_zone}"
    count = "${var.consul_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "${var.consul_private_key}"
}
