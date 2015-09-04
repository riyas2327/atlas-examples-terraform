variable "name" {}

resource "aws_key_pair" "key" {
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/${var.name}.pub")}"
}

output "key_name" { value = "${aws_key_pair.key.key_name}" }
output "key_path" { value = "${path.module}/keys/${var.name}.pem" }
