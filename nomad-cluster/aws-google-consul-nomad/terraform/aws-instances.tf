data "template_file" "consul_update_aws" {
  template = "${file("${module.shared.path}/consul/deprecated/userdata/consul_update.sh.tpl")}"

  vars {
    region               = "${var.aws_region}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.server_nodes}"
    instance_id_url      = "http://169.254.169.254/2014-02-25/meta-data/instance-id"
    instance_address_url = "http://169.254.169.254/2014-02-25/meta-data/local-ipv4"
  }

  depends_on = ["aws_vpn_gateway.vpn"] // give the VPN some time to connect
}

data "template_file" "pqs_aws" {
  template = "${file("${module.shared.path}/consul/deprecated/userdata/pqs.sh.tpl")}"
}

//
// Consul & Nomad Servers
//
resource "aws_instance" "server" {
  count         = "${var.server_nodes}"
  instance_type = "${var.aws_instance_type}"
  ami           = "${var.aws_source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.internal_access.id}",
  ]

  tags {
    Name = "server_${count.index}"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/deprecated/consul.d/consul_server.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/deprecated/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/nomad/deprecated/installers/nomad_install.sh",
      "${module.shared.path}/consul/deprecated/installers/consul_install.sh",
      "${module.shared.path}/consul/deprecated/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/deprecated/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.consul_update_aws.rendered}",
      "${data.template_file.pqs_aws.rendered}",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
name       = "${self.id}"
data_dir   = "/opt/nomad/data"
region     = "${var.aws_region}"
datacenter = "${var.aws_region}"

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
    source      = "${module.shared.path}/nomad/deprecated/init/nomad.conf"
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

//
// Nomad & Consul Clients
//
resource "aws_instance" "client" {
  count         = "${var.client_nodes}"
  instance_type = "${var.aws_instance_type}"
  ami           = "${var.aws_source_ami}"
  key_name      = "${aws_key_pair.main.key_name}"
  subnet_id     = "${aws_subnet.subnet_a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.default_egress.id}",
    "${aws_security_group.admin_access.id}",
    "${aws_security_group.internal_access.id}",
  ]

  tags {
    Name = "client_${count.index}"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/deprecated/consul.d/consul_client.json"
    destination = "/tmp/consul.json.tmp"
  }

  provisioner "file" {
    source      = "${module.shared.path}/consul/deprecated/init/consul.conf"
    destination = "/tmp/consul.conf"
  }

  provisioner "remote-exec" {
    scripts = [
      "${module.shared.path}/nomad/deprecated/installers/docker_install.sh",
      "${module.shared.path}/nomad/deprecated/installers/nomad_install.sh",
      "${module.shared.path}/consul/deprecated/installers/consul_install.sh",
      "${module.shared.path}/consul/deprecated/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/deprecated/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.consul_update_aws.rendered}",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
name       = "${self.id}"
data_dir   = "/opt/nomad/data"
region       = "${var.aws_region}"
datacenter   = "${var.aws_region}"

bind_addr = "0.0.0.0"

client {
  enabled    = true

  options {
    "docker.cleanup.image"   = "0"
    "driver.raw_exec.enable" = "1"
  }
}

addresses {
  rpc  = "${self.private_ip}"
  serf = "${self.private_ip}"
}

advertise {
  http = "${self.private_ip}:4646"
}

consul {
}

EOF
CMD
  }

  provisioner "file" {
    source      = "${module.shared.path}/nomad/deprecated/init/nomad.conf"
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
