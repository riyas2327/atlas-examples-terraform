resource "template_file" "consul_update" {
  filename = "${module.shared.path}/consul/userdata/consul_update.sh.tpl"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_organization      = "${var.atlas_organization}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }
}

//
// Consul Client
//
resource "aws_instance" "consul_client" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul_client.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "consul_client"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh"
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_client.json"
    destination = "/etc/consul.d/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/etc/init/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

}

//
// Consul Servers
//
resource "aws_instance" "consul_0" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "consul_0"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh"
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/etc/consul.d/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/etc/init/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

}

resource "aws_instance" "consul_1" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.subnet_b.id}"

  tags {
    Name = "consul_1"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh"
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/etc/consul.d/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/etc/init/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

}

resource "aws_instance" "consul_2" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.subnet_c.id}"

  tags {
    Name = "consul_2"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/consul/installers/consul_install.sh"
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/consul.d/consul_server.json"
    destination = "/etc/consul.d/consul.json.tmp"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.shared.path}/consul/init/consul.conf"
    destination = "/etc/init/consul.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = ["${template_file.consul_update.rendered}"]
  }

}
