resource "template_file" "consul_update" {
  template = "${module.shared.path}/consul/userdata/consul_update.sh.tpl"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_username          = "${var.atlas_username}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }
}

//
// Consul & Nomad Servers
//
resource "aws_instance" "nomad_server_1" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}"
  ]

  tags {
    Name = "nomad_server_1"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh",
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

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
  rpc = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/tmp/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/batch.hcl"
    destination = "/tmp/batch.hcl"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/cache.hcl"
    destination = "/tmp/cache.hcl"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/web.hcl"
    destination = "/tmp/web.hcl"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

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

resource "aws_instance" "nomad_server_2" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_b.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}"
  ]

  tags {
    Name = "nomad_server_2"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh",
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

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
  rpc = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/tmp/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/batch.hcl"
    destination = "/tmp/batch.hcl"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/cache.hcl"
    destination = "/tmp/cache.hcl"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/web.hcl"
    destination = "/tmp/web.hcl"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo mv /tmp/batch.hcl /opt/nomad/jobs/",
      "sudo mv /tmp/cache.hcl /opt/nomad/jobs/",
      "sudo mv /tmp/web.hcl /opt/nomad/jobs/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join ${aws_instance.nomad_server_1.private_ip}"
  }
}

resource "aws_instance" "nomad_server_3" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_c.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}"
  ]

  tags {
    Name = "nomad_server_3"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh",
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

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
  rpc = "${self.private_ip}"
  serf = "${self.private_ip}"
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/tmp/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/batch.hcl"
    destination = "/tmp/batch.hcl"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/cache.hcl"
    destination = "/tmp/cache.hcl"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/jobs/web.hcl"
    destination = "/tmp/web.hcl"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo mv /tmp/batch.hcl /opt/nomad/jobs/",
      "sudo mv /tmp/cache.hcl /opt/nomad/jobs/",
      "sudo mv /tmp/web.hcl /opt/nomad/jobs/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join ${aws_instance.nomad_server_1.private_ip}"
  }
}

//
// Nomad & Consul Clients
//
resource "aws_instance" "nomad_client" {
  instance_type = "${var.instance_type}"
  ami           = "${var.source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.nomad.id}"
  ]

  tags {
    Name = "nomad_client_${count.index+1}"
  }

  count = "${var.nomad_client_nodes}"

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_client.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/docker_install.sh",
      "${module.shared.path}/nomad/installers/nomad_install.sh",
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
datacenter = "${var.region}"

consul {
}

client {
  enabled = true
  servers = [
    "${aws_instance.nomad_server_1.private_ip}:4647",
    "${aws_instance.nomad_server_2.private_ip}:4647",
    "${aws_instance.nomad_server_3.private_ip}:4647"
  ]
}

EOF
CMD
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/nomad/init/nomad.conf"
    destination = "/tmp/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/docker_install.sh",
      "${module.shared.path}/nomad/installers/nomad_install.sh",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }
}
