output "nomad_0" {
  value = "${aws_instance.nomad_0.private_ip} - ${aws_instance.nomad_0.public_ip}"
}

output "nomad_1" {
  value = "${aws_instance.nomad_1.private_ip} - ${aws_instance.nomad_1.public_ip}"
}

output "nomad_2" {
  value = "${aws_instance.nomad_2.private_ip} - ${aws_instance.nomad_2.public_ip}"
}
