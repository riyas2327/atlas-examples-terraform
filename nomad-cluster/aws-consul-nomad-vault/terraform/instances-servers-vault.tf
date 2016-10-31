resource "aws_instance" "server_vault" {
  ami           = "${data.aws_ami.ubuntu_trusty.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${element(aws_subnet.main.*.id,count.index)}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}",
  ]

  tags {
    Name = "server-vault-${count.index}"
  }

  count = "${var.server_nodes}"

  connection {
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
  }

  #
  # Consul
  #
  provisioner "file" {
    source      = "${module.shared.path}/consul/consul.d/consul_client.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.consul_update.rendered}"]
  }

  #
  # Vault
  #
  provisioner "file" {
    source      = "${module.shared.path}/vault/vault.d/vault.hcl.tpl"
    destination = "/tmp/vault.hcl.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/vault/init/vault.conf"
    destination = "/tmp/vault.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/vault/installers/vault_install.sh",
      "${module.shared.path}/vault/installers/vault_conf_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = ["${data.template_file.vault_update.rendered}"]
  }

}
