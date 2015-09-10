variable "atlas_username" {}
variable "name" {}

resource "atlas_artifact" "consul_latest" {
  name = "${var.atlas_username}/${var.name}-consul"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "consul_pinned" {
  name = "${var.atlas_username}/${var.name}-consul"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "vault_latest" {
  name = "${var.atlas_username}/${var.name}-vault"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "vault_pinned" {
  name = "${var.atlas_username}/${var.name}-vault"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "rabbitmq_latest" {
  name = "${var.atlas_username}/${var.name}-rabbitmq"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "rabbitmq_pinned" {
  name = "${var.atlas_username}/${var.name}-rabbitmq"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "app_latest" {
  name = "${var.atlas_username}/${var.name}-app"
  type = "amazon.ami"
  version = "latest"
}

resource "atlas_artifact" "app_pinned" {
  name = "${var.atlas_username}/${var.name}-app"
  type = "amazon.ami"
  version = "latest"
}

output "consul_latest" { value = "${atlas_artifact.consul_latest.metadata_full.region-us-east-1}" }
output "consul_pinned" { value = "${atlas_artifact.consul_pinned.metadata_full.region-us-east-1}" }
output "vault_latest" { value = "${atlas_artifact.vault_latest.metadata_full.region-us-east-1}" }
output "vault_pinned" { value = "${atlas_artifact.vault_pinned.metadata_full.region-us-east-1}" }
output "rabbitmq_latest" { value = "${atlas_artifact.rabbitmq_latest.metadata_full.region-us-east-1}" }
output "rabbitmq_pinned" { value = "${atlas_artifact.rabbitmq_pinned.metadata_full.region-us-east-1}" }
output "app_latest" { value = "${atlas_artifact.app_latest.metadata_full.region-us-east-1}" }
output "app_pinned" { value = "${atlas_artifact.app_pinned.metadata_full.region-us-east-1}" }
