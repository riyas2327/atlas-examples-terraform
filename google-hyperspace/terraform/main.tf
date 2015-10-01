// Copyright 2015 Google Inc. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

provider "google" {
  account_file = "${file("../packer/pkey.json")}"
  project      = "${var.GOOGLE_PROJECT_ID}"
  region       = "us-central1"
}

//
// ARTIFACTS
//
resource "atlas_artifact" "hyperspace-be" {
  name = "${var.ATLAS_USERNAME}/hyperspace-be"
  type = "google.image"
}

resource "atlas_artifact" "hyperspace-fe" {
  name = "${var.ATLAS_USERNAME}/hyperspace-fe"
  type = "google.image"
}

//
// INSTANCES
//
resource "google_compute_instance" "hyperspace-be" {
  name         = "hyperspace-be"
  machine_type = "n1-standard-1"
  zone         = "us-central1-f"

  disk {
      image = "${atlas_artifact.hyperspace-be.id}"
  }

  network_interface {
      network = "default"
      access_config {
          // Ephemeral IP
      }
  }
  count = 1
  lifecycle = {
    create_before_destroy = true
  }
}

resource "google_compute_instance" "hyperspace-fe" {
  name         = "${format("hyperspace-fe-%d", count.index)}"
  machine_type = "n1-standard-1"
  zone         = "us-central1-f"
  tags         = ["hyperspace"]

  disk {
      image = "${atlas_artifact.hyperspace-fe.id}"
  }

  network_interface {
      network = "default"
      access_config {
          // Ephemeral IP
      }
  }
  count = 3
  lifecycle = {
    create_before_destroy = true
  }
}

//
// NETWORKING
//
resource "google_compute_firewall" "fwrule" {
    name = "hyperspace-web"
    network = "default"
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
    target_tags = ["hyperspace"]
}

resource "google_compute_forwarding_rule" "fwd_rule" {
    name = "fwdrule"
    target = "${google_compute_target_pool.tpool.self_link}"
    port_range = "80"
}

resource "google_compute_target_pool" "tpool" {
    name = "tpool"
    instances = [
        "${google_compute_instance.hyperspace-fe.*.self_link}"
    ]
}

output "lb_ip" {
  value = "${google_compute_forwarding_rule.fwd_rule.ip_address}"
}

