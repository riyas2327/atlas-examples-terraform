data "template_file" "consul_update" {
  template = "${file("${module.shared.path}/consul/userdata/consul_update.sh.tpl")}"

  vars {
    region               = "${data.aws_region.main.name}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.consul_server_nodes}"
    instance_id_url      = "http://169.254.169.254/2014-02-25/meta-data/instance-id"
    instance_address_url = "http://169.254.169.254/2014-02-25/meta-data/local-ipv4"
  }
}

data "template_file" "vault_update" {
  template = "${file("${module.shared.path}/vault/userdata/vault_update.sh.tpl")}"

  vars {
    atlas_environment    = "${var.atlas_environment}"
  }
}
