variable "region" {}
variable "atlas_token" {}
variable "atlas_username" {}
variable "atlas_environment" {}

variable "server_nodes" {
  default = "3"
}

data "template_file" "install_consul_client" {
  template = "${file("${path.module}/consul/provision-consul-client.sh.tpl")}"

  vars {
    region               = "${var.region}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.server_nodes}"
    instance_id_url      = "http://169.254.169.254/2014-02-25/meta-data/instance-id"
  }
}

output "install_consul_client" {
  value = "${data.template_file.install_consul_client.rendered}"
}

data "template_file" "install_consul_server" {
  template = "${file("${path.module}/consul/provision-consul-server.sh.tpl")}"

  vars {
    region               = "${var.region}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.server_nodes}"
    instance_id_url      = "http://169.254.169.254/2014-02-25/meta-data/instance-id"
  }
}

output "install_consul_server" {
  value = "${data.template_file.install_consul_server.rendered}"
}

data "template_file" "install_nomad_server" {
  template = "${file("${path.module}/nomad/provision-nomad-server.sh.tpl")}"

  vars {
    region               = "${var.region}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.server_nodes}"
    instance_id_url      = "http://169.254.169.254/2014-02-25/meta-data/instance-id"
  }
}

output "install_nomad_server" {
  value = "${data.template_file.install_nomad_server.rendered}"
}

data "template_file" "install_nomad_client" {
  template = "${file("${path.module}/nomad/provision-nomad-client.sh.tpl")}"

  vars {
    region               = "${var.region}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.server_nodes}"
    instance_id_url      = "http://169.254.169.254/2014-02-25/meta-data/instance-id"
  }
}

output "install_nomad_client" {
  value = "${data.template_file.install_nomad_client.rendered}"
}

data "template_file" "vault_update" {
  template = "${file("${path.module}/vault/userdata/vault_update.sh.tpl")}"

  vars {
    atlas_environment       = "${var.atlas_environment}"
  }
}

output "vault_update" {
  value = "${data.template_file.vault_update.rendered}"
}
