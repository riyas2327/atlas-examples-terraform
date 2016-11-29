resource "aws_instance" "server_consul" {
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
    Name = "${var.atlas_environment}-server-consul-${count.index}"
    consul_server_datacenter = "${data.aws_region.main.name}"
  }

  count = "${var.consul_server_nodes}"

  connection {
    user        = "${module.shared.base_user}"
    private_key = "${file(module.shared.private_key_path)}"
  }

  #
  # Consul
  #
  provisioner "remote-exec" {
    inline = ["${module.shared.install_consul_server}"]
  }
}
