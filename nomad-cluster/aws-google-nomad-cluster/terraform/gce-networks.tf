resource "google_compute_network" "main" {
  name       = "${var.atlas_environment}"
  ipv4_range = "${var.gce_vpc_cidr}"
}