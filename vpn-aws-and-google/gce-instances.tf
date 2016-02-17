resource "template_file" "consul_update_gce" {
  template = "${module.shared.path}/consul/userdata/consul_update_gce.sh.tpl"

  vars {
    region                  = "${var.gce_region}"
    atlas_token             = "${var.atlas_token}"
    atlas_username          = "${var.atlas_username}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }

  depends_on = ["google_compute_vpn_gateway.vpn"] // give the VPN some time to connect
}

/*
NOTE: The instances here will be launched with Nomad and Consul joined
within the provider first. Then a null_resource will check the VPN
connectivity before joining across the wan.
*/

resource "google_compute_instance" "nomad_server_1" {
  name         = "${var.atlas_environment}-nomad-server-1"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-a"

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

  tags = ["admin"]

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
    inline = ["${template_file.consul_update_gce.rendered}"]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
region = "${var.nomad_region}"
datacenter = "${var.gce_region}"

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
  rpc = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
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
      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
      "sudo service dnsmasq restart",
    ]
  }
}

resource "google_compute_instance" "nomad_server_2" {
  name         = "${var.atlas_environment}-nomad-server-2"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-a"

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

  tags = ["admin"]

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
    inline = ["${template_file.consul_update_gce.rendered}"]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
region = "${var.nomad_region}"
datacenter = "${var.gce_region}"

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
  rpc = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
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
      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
      "sudo service dnsmasq restart",
    ]
  }

  provisioner "remote-exec" {
    inline = "echo -n 'Joining Nomad... ' && nomad server-join ${google_compute_instance.nomad_server_1.network_interface.0.address}"
    inline = "echo -n 'Joining Consul... ' && consul join ${google_compute_instance.nomad_server_1.network_interface.0.address}"
  }
}

resource "google_compute_instance" "nomad_server_3" {
  name         = "${var.atlas_environment}-nomad-server-3"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-a"

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

  tags = ["admin"]

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
    inline = ["${template_file.consul_update_gce.rendered}"]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
region = "${var.nomad_region}"
datacenter = "${var.gce_region}"

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
  rpc = "${self.network_interface.0.address}"
  serf = "${self.network_interface.0.address}"
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
      "sudo sed -i -- 's/listen-address=127.0.0.1/listen-address=0.0.0.0/g' /etc/dnsmasq.d/consul",
      "sudo service dnsmasq restart",
    ]
  }

  provisioner "remote-exec" {
    inline = "echo -n 'Joining Nomad... ' && nomad server-join ${google_compute_instance.nomad_server_1.network_interface.0.address}"
    inline = "echo -n 'Joining Consul... ' && consul join ${google_compute_instance.nomad_server_1.network_interface.0.address}"
  }
}

resource "google_compute_instance" "nomad_client" {
  name         = "${var.atlas_environment}-nomad-client-${count.index+1}"
  machine_type = "${var.gce_instance_type}"
  zone         = "${var.gce_region}-a"

  count = "${var.nomad_client_nodes}"

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

  tags = ["admin"]

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
    inline = ["${template_file.consul_update_gce.rendered}"]
  }

  provisioner "remote-exec" {
    inline = <<CMD
cat > /tmp/nomad.hcl <<EOF
data_dir = "/opt/nomad/data"
log_level = "DEBUG"
region = "${var.nomad_region}"
datacenter = "${var.gce_region}"

atlas {
  infrastructure = "${var.atlas_username}/${var.atlas_environment}"
  token = "${var.atlas_token}"
}

consul {
}

client {
  enabled = true
  servers = [
    "${google_compute_instance.nomad_server_1.network_interface.0.address}:4647",
    "${google_compute_instance.nomad_server_2.network_interface.0.address}:4647",
    "${google_compute_instance.nomad_server_3.network_interface.0.address}:4647"
  ]
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
      "consul join ${google_compute_instance.nomad_server_1.network_interface.0.address}",
      "sudo mv /tmp/nomad.hcl  /etc/nomad.d/",
      "sudo mv /tmp/nomad.conf /etc/init/",
      "sudo service nomad start || sudo service nomad restart",
    ]
  }

}

resource "null_resource" "gce_join_wan" {
  depends_on = [
    "google_compute_vpn_tunnel.tunnel1",
    "google_compute_vpn_tunnel.tunnel2",
    "aws_instance.nomad_server_1",
    "google_compute_instance.nomad_server_1",
  ]
  connection {
    host = "${google_compute_instance.nomad_server_1.network_interface.0.access_config.0.assigned_nat_ip}"
    user     = "ubuntu"
    key_file = "${module.shared.private_key_path}"
  }

  # this provisioner must be separate from the join commands below
  provisioner "remote-exec" {
    inline = [
      # test WAN connectivity over VPN - bash is needed so the for loop short circuits correctly
      "bash -c 'for i in {1..${var.vpn_wait_timeout}}; do ping -q -c1 -W1 ${aws_instance.nomad_server_1.private_ip} && break; done;'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      # proceed with join if connectivity test passed
      "echo -n 'Joining Nomad (WAN)... ' && nomad server-join ${aws_instance.nomad_server_1.private_ip}",
      "echo -n 'Joining Consul (WAN)... ' && consul join -wan ${aws_instance.nomad_server_1.private_ip}",
    ]
  }
}
