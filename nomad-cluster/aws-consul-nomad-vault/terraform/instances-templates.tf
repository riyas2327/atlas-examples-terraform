data "template_file" "consul_update" {
  template = "${file("${module.shared.path}/consul/userdata/consul_update.sh.tpl")}"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_username          = "${var.atlas_username}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
    instance_address_url    = "http://169.254.169.254/2014-02-25/meta-data/local-ipv4"
  }
}

data "template_file" "vault_update" {
  template = "${file("${module.shared.path}/vault/userdata/vault_update.sh.tpl")}"

  vars {
    region = "${var.region}"
  }
}
