variable "name" {}

output "name"          { value = "${var.name}" }
output "crt_path"      { value = "${path.module}/certs/${var.name}.crt" }
output "key_path"      { value = "${path.module}/certs/${var.name}.key" }
