variable "atlas_username"          {}
variable "consul_latest_name"      { default = "aws-ubuntu-consul" }
variable "consul_pinned_name"      { default = "aws-ubuntu-consul" }
variable "consul_pinned_version"   { default = "latest" }
variable "vault_latest_name"       { default = "aws-ubuntu-vault" }
variable "vault_pinned_name"       { default = "aws-ubuntu-vault" }
variable "vault_pinned_version"    { default = "latest" }
variable "rabbitmq_latest_name"    { default = "aws-ubuntu-rabbitmq" }
variable "rabbitmq_pinned_name"    { default = "aws-ubuntu-rabbitmq" }
variable "rabbitmq_pinned_version" { default = "latest" }
variable "web_latest_name"         { default = "aws-windows-web" }
variable "web_pinned_name"         { default = "aws-windows-web" }
variable "web_pinned_version"      { default = "latest" }

resource "atlas_artifact" "consul_latest" {
  name = "${var.atlas_username}/${var.consul_latest_name}"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "consul_pinned" {
  name = "${var.atlas_username}/${var.consul_pinned_name}"
  type = "amazon.ami"
  version = "${var.consul_pinned_version}"
}

resource "atlas_artifact" "vault_latest" {
  name = "${var.atlas_username}/${var.vault_latest_name}"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "vault_pinned" {
  name = "${var.atlas_username}/${var.vault_pinned_name}"
  type = "amazon.ami"
  version = "${var.vault_pinned_version}"
}

resource "atlas_artifact" "rabbitmq_latest" {
  name = "${var.atlas_username}/${var.rabbitmq_latest_name}"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "rabbitmq_pinned" {
  name = "${var.atlas_username}/${var.rabbitmq_pinned_name}"
  type = "amazon.ami"
  version = "${var.rabbitmq_pinned_version}"
}

resource "atlas_artifact" "web_latest" {
  name = "${var.atlas_username}/${var.web_latest_name}"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "web_pinned" {
  name = "${var.atlas_username}/${var.web_pinned_name}"
  type = "amazon.ami"
  version = "${var.web_pinned_version}"
}

output "consul_latest"   { value = "${atlas_artifact.consul_latest.metadata_full.region-us-east-1}" }
output "consul_pinned"   { value = "${atlas_artifact.consul_pinned.metadata_full.region-us-east-1}" }
output "vault_latest"    { value = "${atlas_artifact.vault_latest.metadata_full.region-us-east-1}" }
output "vault_pinned"    { value = "${atlas_artifact.vault_pinned.metadata_full.region-us-east-1}" }
output "rabbitmq_latest" { value = "${atlas_artifact.rabbitmq_latest.metadata_full.region-us-east-1}" }
output "rabbitmq_pinned" { value = "${atlas_artifact.rabbitmq_pinned.metadata_full.region-us-east-1}" }
output "web_latest"      { value = "${atlas_artifact.web_latest.metadata_full.region-us-east-1}" }
output "web_pinned"      { value = "${atlas_artifact.web_pinned.metadata_full.region-us-east-1}" }
