resource "aws_instance" "server_nomad" {
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
    Name = "${var.atlas_environment}-server-nomad-${count.index}"
  }

  count = "${var.nomad_server_nodes}"

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
    inline = ["${module.shared.install_nomad_server}"]
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/jobs"
    destination = "./"
  }
}
