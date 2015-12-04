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

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo start nomad || sudo restart nomad",
    ]
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

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo start nomad || sudo restart nomad",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join ${aws_instance.nomad_0.private_ip}"
  }

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

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = [
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo start nomad || sudo restart nomad",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    inline = "nomad server-join ${aws_instance.nomad_0.private_ip}"
  }

}

//
// Consul Servers
//

module "consul" {
  source = "../../../consul-cluster/aws-beginner-consul-cluster"
  # source = "github.com/hashicorp/atlas-examples/consul-cluster/aws-beginner-consul-cluster"

  atlas_token       = "${var.atlas_token}"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
}


resource "template_file" "consul_update" {
  filename = "${module.consul.shared_path}/consul/userdata/consul_update.sh.tpl"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_username          = "${var.atlas_username}"
    atlas_environment       = "${var.atlas_environment}"
  }
}

//
// Nomad Clients
//
resource "aws_instance" "nomad_client" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.source_ami}"
  key_name               = "${aws_key_pair.main.key_name}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.nomad.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "nomad_client"
  }

  count = 3

  provisioner "remote-exec" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    scripts = [
      "${module.consul.shared_path}/consul/installers/consul_install.sh",
      "${module.consul.shared_path}/consul/installers/dnsmasq_install.sh",
      "${module.shared.path}/nomad/installers/docker_install.sh",
      "${module.shared.path}/nomad/installers/nomad_install.sh"
    ]
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.consul.shared_path}/consul/consul.d/consul_client.json"
    destination = "/etc/consul.d/consul.json"
  }

  provisioner "file" {
    connection {
      user     = "ubuntu"
      key_file = "${module.shared.private_key_path}"
      agent    = "false"
    }

    source      = "${module.consul.shared_path}/consul/init/consul.conf"
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
  servers = ["${aws_instance.nomad_0.private_ip}:4647","${aws_instance.nomad_1.private_ip}:4647","${aws_instance.nomad_2.private_ip}:4647"]
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
      "sudo start nomad || sudo restart nomad",
    ]
  }
}
