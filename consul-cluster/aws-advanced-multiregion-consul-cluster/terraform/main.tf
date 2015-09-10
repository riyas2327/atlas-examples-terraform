provider "aws" {
  alias      = "east"
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

provider "aws" {
  alias      = "west"
  region     = "${var.region_west}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

module "shared" {
  source       = "../../shared"
  key_name = "${var.key_name}"
}
