resource "template_file" "consul_update_gce" {
  template = "${module.shared.path}/consul/userdata/consul_update.sh.tpl"

  vars {
    region                  = "${var.gce_region}"
    atlas_token             = "${var.atlas_token}"
    atlas_username          = "${var.atlas_username}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.gce_servers}"
    instance_address_url    = "-H \"Metadata-Flavor: Google\" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip"
  }

  depends_on = ["google_compute_vpn_gateway.vpn"] // give the VPN some time to connect
}

resource "template_file" "pqs_gce" {
  template = "${module.shared.path}/consul/userdata/pqs.sh.tpl"
}

/*
NOTE: The instances here will be launched with Nomad and Consul joined
within the provider first. Then a null_resource will check the VPN
connectivity before joining across the wan.
*/

resource "google_compute_instance" "server" {
  count        = "${var.gce_servers}"
  name         = "${var.atlas_environment}-nomad-server-${count.index + 1}"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-b"

  disk {
    image = "${var.gce_source_image}"
  }

  network_interface {
    network = "${google_compute_network.main.name}"

    access_config {
    }
  }

  metadata {
    sshKeys = "ubuntu:${file(module.shared.public_key_path)}"
  }

  tags = ["nomad-server-${count.index + 1}"]

  connection {
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

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
      "${module.shared.path}/nomad/installers/nomad_install.sh",
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "${template_file.consul_update_gce.rendered}",
      "${template_file.pqs_gce.rendered}",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir     = "/opt/nomad/data"
enable_debug = true
bind_addr    = "0.0.0.0"
region       = "${var.gce_region}"
datacenter   = "${var.gce_region}"
node_id      = "gce-server-${count.index + 1}"
log_level    = "DEBUG"

advertise {
  http = "${self.network_interface.0.address}:4646"
  rpc  = "${self.network_interface.0.address}:4647"
  serf = "${self.network_interface.0.address}:4648"
}

consul {
}

atlas {
  infrastructure = "${var.atlas_username}/${var.atlas_environment}"
  token          = "${var.atlas_token}"
}

addresses {
  rpc  = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
}

server {
  enabled          = true
  bootstrap_expect = ${var.gce_servers}
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
      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
      "sudo service dnsmasq restart",
    ]
  }
}

resource "null_resource" "gce_server_join" {
  count = "${var.gce_servers}"

  depends_on = [
    "google_compute_instance.server",
  ]

  connection {
    host = "${element(google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip, count.index)}"
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo -n 'Joining Nomad... ' && nomad server-join ${join(" ", google_compute_instance.server.*.network_interface.0.address)}",
      "echo -n 'Joining Consul... ' && consul join ${join(" ", google_compute_instance.server.*.network_interface.0.address)}",
    ]
  }
}

resource "null_resource" "gce_wan_join" {
  count = "${var.gce_servers}"

  depends_on = [
    "google_compute_vpn_tunnel.tunnel1",
    "google_compute_vpn_tunnel.tunnel2",
    "google_compute_instance.server",
    "aws_instance.server",
    "null_resource.gce_server_join",
  ]

  connection {
    host = "${element(google_compute_instance.server.*.network_interface.0.access_config.0.assigned_nat_ip, count.index)}"
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  # This provisioner must be separate from the join commands below
  provisioner "remote-exec" {
    inline = [
      # Test WAN connectivity over VPN - bash is needed so the for loop short circuits correctly
      "bash -c 'for i in {1..${var.vpn_wait_timeout}}; do ping -q -c1 -W1 ${aws_instance.server.0.private_ip} 1>/dev/null && break; done;'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      # Proceed with join if connectivity test passed
      "echo -n 'Joining Nomad (WAN)... ' && nomad server-join ${join(" ", aws_instance.server.*.private_ip)}",
      "echo -n 'Joining Consul (WAN)... ' && consul join -wan ${join(" ", aws_instance.server.*.private_ip)}",
    ]
  }
}

resource "google_compute_instance" "nomad_client" {
  count        = "${var.gce_nomad_clients}"
  name         = "${var.atlas_environment}-nomad-client-${count.index+1}"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-b"

  disk {
    image = "${var.gce_source_image}"
  }

  network_interface {
    network = "${google_compute_network.main.name}"

    access_config {
    }
  }

  metadata {
    sshKeys = "ubuntu:${file(module.shared.public_key_path)}"
  }

  tags = [
    "nomad-client-${count.index + 1}"
  ]

  connection {
    user        = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

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
      "${module.shared.path}/nomad/installers/docker_install.sh",
      "${module.shared.path}/nomad/installers/nomad_install.sh",
      "${module.shared.path}/consul/installers/consul_install.sh",
      "${module.shared.path}/consul/installers/consul_conf_install.sh",
      "${module.shared.path}/consul/installers/dnsmasq_install.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "${template_file.consul_update_gce.rendered}",
    ]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir     = "/opt/nomad/data"
enable_debug = true
bind_addr    = "0.0.0.0"
region       = "${var.gce_region}"
datacenter   = "${var.gce_region}"
node_id      = "gce-nomad-client-${count.index + 1}"
log_level    = "DEBUG"

advertise {
  http = "${self.network_interface.0.address}:4646"
  rpc  = "${self.network_interface.0.address}:4647"
  serf = "${self.network_interface.0.address}:4648"
}

consul {
}

atlas {
  infrastructure = "${var.atlas_username}/${var.atlas_environment}"
  token          = "${var.atlas_token}"
}

client {
  enabled    = true
  node_id    = "gce-nomad-client-${count.index + 1}"
  node_class = "class_${(count.index % var.gce_nomad_clients) + 1}"
  servers    = [
    ${join(",\n    ", formatlist("\"%s:4647\"", google_compute_instance.server.*.network_interface.0.address))}
  ]

  options {
    "docker.cleanup.image"   = "0"
    "driver.raw_exec.enable" = "1"
  }

  meta {
    region = "${var.gce_region}"
  }
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
      "consul join ${join(" ", google_compute_instance.server.*.network_interface.0.address)}",
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }
}
