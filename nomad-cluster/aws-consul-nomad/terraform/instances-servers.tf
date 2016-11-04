resource "aws_instance" "server" {
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
    Name = "server-${count.index}"
  }

  count = "${var.server_nodes}"

  connection {
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
  }

  #
  # Consul
  #
  provisioner "remote-exec" {
    inline = ["${module.shared.install_consul_server}"]
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
