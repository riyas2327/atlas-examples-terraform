variable "region" {}
variable "atlas_token" {}
variable "atlas_username" {}
variable "atlas_environment" {}

variable "os" {
  default = "ubuntu"
}

variable "consul_server_nodes" {
  default = "3"
}

variable "nomad_server_nodes" {
  default = "3"
}

output "path" {
  value = "${path.module}"
}

output "public_key_path" {
  value = "${path.module}/ssh_keys/atlas-examples.pub"
}

output "private_key_path" {
  value = "${path.module}/ssh_keys/atlas-examples.pem"
}
