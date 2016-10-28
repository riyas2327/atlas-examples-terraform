resource "aws_instance" "client" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${element(list(aws_subnet.subnet_0.id,aws_subnet.subnet_1.id,aws_subnet.subnet_2.id),count.index)}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}",
  ]

  tags {
    Name = "client_${count.index}"
  }

  count = "${var.nomad_client_nodes}"

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
  # Nomad
  #
  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/nomad/installers/docker_install.sh",
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

consul {
}

client {
  enabled = true
}

EOF
CMD
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/tmp/nomad.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }
}
