provider "aws" {}

module "shared" {
  source = "../../shared"

  os                  = "rhel"
  region              = "${data.aws_region.main.name}"
  atlas_token         = "NOT_USED"
  atlas_username      = "NOT_USED"
  atlas_environment   = "${var.environment_name}"
  consul_server_nodes = "${var.consul_server_nodes}"
}

data "aws_region" "main" {
  current = true
}

data "aws_availability_zones" "main" {}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}
