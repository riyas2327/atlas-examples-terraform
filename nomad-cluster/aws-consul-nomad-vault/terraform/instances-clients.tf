resource "aws_instance" "client" {
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
  # Nomad
  #
  provisioner "remote-exec" {
    inline = ["${module.shared.install_nomad_client}"]
  }
}
