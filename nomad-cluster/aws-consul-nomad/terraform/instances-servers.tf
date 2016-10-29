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
    Name = "server_${count.index}"
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
    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
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
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
name       = "${self.id}"
data_dir   = "/opt/nomad/data"
datacenter = "${var.region}"

bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = ${var.server_nodes}
}

addresses {
  rpc  = "${self.private_ip}"
  serf = "${self.private_ip}"
}

advertise {
  http = "${self.private_ip}:4646"
}

EOF
CMD
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/tmp/nomad.conf"
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/jobs/batch.hcl"
    destination = "/tmp/batch.hcl"
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/jobs/cache.hcl"
    destination = "/tmp/cache.hcl"
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/jobs/web.hcl"
    destination = "/tmp/web.hcl"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo mv /tmp/batch.hcl /opt/nomad/jobs/",
      "sudo mv /tmp/cache.hcl /opt/nomad/jobs/",
      "sudo mv /tmp/web.hcl /opt/nomad/jobs/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }

}
