// Copyright 2015 Google Inc. All Rights Reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    source_tags = ["hyperspace"]
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

