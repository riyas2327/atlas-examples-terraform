//Provider
provider "google" {
    account_file = "account.json"
    project = "letschat-example"
    region = "us-central1"
}

// Artifacts
resource "atlas_artifact" "mongodb" {
  name = "${var.atlas_username}/mongodb"
  type = "googlecompute.image"
}

resource "atlas_artifact" "nodejs" {
  name = "${var.atlas_username}/nodejs"
  type = "googlecompute.image"
}

resource "atlas_artifact" "consul" {
  name = "${var.atlas_username}/consul"
  type = "googlecompute.image"
}

resource "atlas_artifact" "haproxy" {
  name = "${var.atlas_username}/haproxy"
  type = "googlecompute.image"
}

// TEMPLATES
resource "template_file" "consul_upstart" {
  filename = "files/consul.sh"

  vars {
    atlas_user_token = "${var.atlas_user_token}"
    atlas_username = "${var.atlas_username}"
    atlas_environment = "${var.atlas_environment}"
    consul_server_count = "${var.consul_server_count}"
    }
}

//Networking
resource "google_compute_network" "letschat-example" {
    name = "letschat-example"
    ipv4_range = "10.0.0.0/16"
}

resource "google_compute_firewall" "allow-all" {
    name = "allow-all"
    network = "${google_compute_network.letschat-example.name}"
    source_ranges = ["0.0.0.0/0"]

    allow {
        protocol = "tcp"
        ports = ["1-65535"]
    }

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "udp"
        ports = ["1-65535"]
    }
}

//Consul Instance
resource "google_compute_instance" "consul" {
  name = "consul-${count.index}-${atlas_artifact.consul.id}"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  disk {
      image = "${atlas_artifact.consul.id}"
  }

  metadata = {
    startup-script = "${template_file.consul_upstart.rendered}"
  }

  network_interface {
      network = "${google_compute_network.letschat-example.id}"
      access_config {
      }
  }

  count = 3
}

//MongoDB Instance
resource "google_compute_instance" "mongodb" {
  name = "mongodb-${atlas_artifact.mongodb.id}"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  disk {
      image = "${atlas_artifact.mongodb.id}"
  }

  metadata = {
    startup-script = "${template_file.consul_upstart.rendered}"
  }

  network_interface {
      network = "${google_compute_network.letschat-example.id}"
      access_config {
      }
  }

}

//Node.js Instance
resource "google_compute_instance" "nodejs" {
  name = "nodejs-${count.index}-${atlas_artifact.nodejs.id}"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  disk {
      image = "${atlas_artifact.nodejs.id}"
  }

  metadata = {
    startup-script = "${template_file.consul_upstart.rendered}"
  }

  network_interface {
      network = "${google_compute_network.letschat-example.id}"
      access_config {
      }
  }
  count = 2

  depends_on = ["google_compute_instance.mongodb"]
}

//haproxy Instance
resource "google_compute_instance" "haproxy" {
  name = "haproxy-${atlas_artifact.haproxy.id}"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  disk {
      image = "${atlas_artifact.haproxy.id}"
  }

  metadata = {
    startup-script = "${template_file.consul_upstart.rendered}"
  }

  network_interface {
      network = "${google_compute_network.letschat-example.id}"
      access_config {
      }
  }

  depends_on = ["google_compute_instance.mongodb"]
}


output "letschat" {
  value = "${google_compute_instance.haproxy.network_interface.0.access_config.0.nat_ip}"
}
