resource "google_compute_firewall" "admin_access" {
  name    = "admin"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["admin"]
}

resource "google_compute_firewall" "internal_access" {
  name    = "internal"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["${var.aws_vpc_cidr}","${var.gce_vpc_cidr}"]
}
