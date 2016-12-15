resource "aws_instance" "client" {
  ami           = "${module.shared.base_image}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${element(aws_subnet.main.*.id,count.index)}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.all.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.describe_instances.name}"

  tags {
    Name = "${var.atlas_environment}-client-${count.index}"
  }

  count = "${var.client_nodes}"

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
      "${module.shared.install_vault_client}",
      "echo 'export VAULT_ADDR=http://localhost:8200' >> /home/${module.shared.base_user}/.bashrc",
    ]
  }

  #
  # VSI
  #
  provisioner "remote-exec" {
    inline = [
      "${file("aws-consul-vault-rds/terraform/templates/vsi-install.sh")}",
    ]
  }

}
