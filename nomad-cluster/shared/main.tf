output "path" {
  value = "${path.module}"
}

output "public_key_path" {
  value = "${path.module}/ssh_keys/atlas-examples.pub"
}

output "private_key_path" {
  value = "${path.module}/ssh_keys/atlas-examples.pem"
}
