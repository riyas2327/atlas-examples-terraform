resource "aws_instance" "server_vault" {
  ami           = "${module.shared.base_image}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${element(aws_subnet.main.*.id,count.index)}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}",
  ]

  tags {
    Name = "${var.atlas_environment}-server-vault-${count.index}"
  }

  count = "${var.vault_server_nodes}"

  connection {
    user        = "${module.shared.base_user}"
    private_key = "${file(module.shared.private_key_path)}"
  }

  #
  # Consul
  #
  provisioner "remote-exec" {
    inline = ["${module.shared.install_consul_client}"]
  }

  #
  # Vault
  #
  provisioner "remote-exec" {
    inline = [
      "${module.shared.install_vault_server}",
      "echo 'export VAULT_ADDR=http://localhost:8200' >> /home/${module.shared.base_user}/.bashrc",
    ]
  }
}
