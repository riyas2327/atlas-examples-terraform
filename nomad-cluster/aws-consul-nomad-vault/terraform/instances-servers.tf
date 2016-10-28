resource "aws_instance" "server_0" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_0.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}",
  ]

  tags {
    Name = "server_0"
  }

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
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

atlas {
  infrastructure = "${var.atlas_username}/${var.atlas_environment}"
  token = "${var.atlas_token}"
}

server {
  enabled = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}

addresses {
  http = "127.0.0.1"
  rpc  = "${self.private_ip}"
  serf = "${self.private_ip}"
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
//      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
//      "sudo service dnsmasq restart",
    ]
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

resource "aws_instance" "server_1" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_1.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}",
  ]

  tags {
    Name = "server_1"
  }

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
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

atlas {
  infrastructure = "${var.atlas_username}/${var.atlas_environment}"
  token = "${var.atlas_token}"
}

server {
  enabled = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}

addresses {
  http = "127.0.0.1"
  rpc  = "${self.private_ip}"
  serf = "${self.private_ip}"
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
//      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
//      "sudo service dnsmasq restart",
    ]
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

resource "aws_instance" "server_2" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_2.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}",
  ]

  tags {
    Name = "server_2"
  }

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
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

server {
  enabled = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}

addresses {
  http = "127.0.0.1"
  rpc  = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  connection {
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
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
      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
      "sudo service dnsmasq restart",
    ]
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
