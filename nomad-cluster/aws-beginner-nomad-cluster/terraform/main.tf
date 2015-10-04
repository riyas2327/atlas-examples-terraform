provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

module "shared" {
  source = "../../shared"
  key_name = "${var.key_name}"
}

output "nomad_0" {
  value = "${aws_instance.nomad_0.private_ip} - ${aws_instance.nomad_0.public_ip}"
}

output "nomad_1" {
  value = "${aws_instance.nomad_1.private_ip} - ${aws_instance.nomad_1.public_ip}"
}

output "nomad_2" {
  value = "${aws_instance.nomad_2.private_ip} - ${aws_instance.nomad_2.public_ip}"
}

output "nomad clients" {
  value = "${join(", ", aws_instance.nomad_client.*.public_ip)}"
}
