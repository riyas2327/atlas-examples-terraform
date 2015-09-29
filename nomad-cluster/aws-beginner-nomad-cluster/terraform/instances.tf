/*resource "template_file" "consul_update" {
  filename = "${module.shared.path}/consul/userdata/consul_update.sh.tpl"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_organization      = "${var.atlas_organization}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }
}*/

//
// Nomad Servers
//
resource "aws_instance" "nomad_0" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_0"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
bind_addr = "${self.private_ip}"

server {
  enabled = true
  bootstrap_expect = 3

  log_level = "DEBUG"
  enable_debug = true
  disable_update_check = true
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
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

}

resource "aws_instance" "nomad_1" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_1"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
bind_addr = "${self.private_ip}"

server {
  enabled = true
  bootstrap_expect = 3

  log_level = "DEBUG"
  enable_debug = true
  disable_update_check = true
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
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join -address=http://${self.private_ip}:4646 ${aws_instance.nomad_0.private_ip}"
  }

  depends_on = ["aws_instance.nomad_0"]

}

resource "aws_instance" "nomad_2" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_2"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = <<CMD
cat > /etc/nomad.d/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
bind_addr = "${self.private_ip}"

server {
  enabled = true
  bootstrap_expect = 3

  log_level = "DEBUG"
  enable_debug = true
  disable_update_check = true
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
    destination = "/etc/init/nomad.conf"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "sudo start nomad || sudo restart nomad"
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join -address=http://${self.private_ip}:4646 ${aws_instance.nomad_0.private_ip}"
  }

  depends_on = ["aws_instance.nomad_0"]

}
