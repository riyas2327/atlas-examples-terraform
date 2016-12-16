data "template_file" "consul_update_gce" {
  template = "${file("${module.shared.path}/consul/deprecated/userdata/consul_update.sh.tpl")}"

  vars {
    region               = "${var.gce_region}"
    atlas_token          = "${var.atlas_token}"
    atlas_username       = "${var.atlas_username}"
    atlas_environment    = "${var.atlas_environment}"
    server_nodes         = "${var.nomad_server_nodes}"
    instance_id_url      = "-H \"Metadata-Flavor: Google\" http://169.254.169.254/computeMetadata/v1/instance/hostname | cut -d'.' -f1"
    instance_address_url = "-H \"Metadata-Flavor: Google\" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip"
  }

  depends_on = ["google_compute_vpn_gateway.vpn"] // give the VPN some time to connect
}

data "template_file" "pqs_gce" {
  template = "${file("${module.shared.path}/consul/deprecated/userdata/pqs.sh.tpl")}"
}

/*
NOTE: The instances here will be launched with Nomad and Consul joined
within the provider first. Then a null_resource will check the VPN
connectivity before joining across the wan.
*/

resource "google_compute_instance" "server" {
  count        = "${var.nomad_server_nodes}"
  name         = "${var.atlas_environment}-server-${count.index}"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-b"

  disk {
    image = "${var.gce_source_image}"
  }

  network_interface {
    network = "${google_compute_network.main.name}"

    access_config {}
  }

  metadata {
    sshKeys = "ubuntu:${file(module.shared.public_key_path)}"
  }

  tags = [
    "server-${count.index}",
  ]

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
      "${data.template_file.consul_update_gce.rendered}",
      "${data.template_file.pqs_gce.rendered}",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
name       = "${self.id}"
data_dir   = "/opt/nomad/data"
region     = "${var.gce_region}"
datacenter = "${var.gce_region}"

bind_addr = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = ${var.nomad_server_nodes}
}

addresses {
  rpc  = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
}

advertise {
  http = "${self.network_interface.0.address}:4646"
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

resource "google_compute_instance" "client" {
  count        = "${var.client_nodes}"
  name         = "${var.atlas_environment}-client-${count.index}"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-b"

  disk {
    image = "${var.gce_source_image}"
  }

  network_interface {
    network = "${google_compute_network.main.name}"

    access_config {}
  }

  metadata {
    sshKeys = "ubuntu:${file(module.shared.public_key_path)}"
  }

  tags = [
    "client-${count.index}",
  ]

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
      "${data.template_file.consul_update_gce.rendered}",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
name       = "${self.id}"
data_dir   = "/opt/nomad/data"
region     = "${var.gce_region}"
datacenter = "${var.gce_region}"

bind_addr = "0.0.0.0"

client {
  enabled = true
}

addresses {
  rpc  = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
}

advertise {
  http = "${self.network_interface.0.address}:4646"
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

resource "null_resource" "gce_wan_join" {
  count = "${var.nomad_server_nodes}"

  depends_on = [
    "google_compute_vpn_tunnel.tunnel1",
    "google_compute_vpn_tunnel.tunnel2",
    "google_compute_instance.server",
    "aws_instance.server",
  ]

  connection {
    host        = "${element(google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip, count.index)}"
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
  }

  # This provisioner must be separate from the join commands below
  provisioner "remote-exec" {
    inline = [
      "bash -c 'for i in {1..${var.vpn_wait_timeout}}; do ping -q -c1 -W1 ${aws_instance.server.0.private_ip} 1>/dev/null && break; done;'",
    ]
  }

  # Test WAN connectivity over VPN - bash is needed so the for loop short circuits correctly
  provisioner "remote-exec" {
    inline = [
      "echo -n 'Joining Nomad (WAN)... ' && nomad server-join ${join(" ", aws_instance.server.*.private_ip)}",
    ]
  }
}
