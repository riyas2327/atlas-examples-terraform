provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

module "shared" {
  source = "../../shared"
  key_name = "${var.key_name}"
}
