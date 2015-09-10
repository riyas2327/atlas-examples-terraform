output "west_consul_client" {
  value = "${aws_instance.west_consul_client.private_ip} - ${aws_instance.west_consul_client.public_ip}"
}

output "west_consul_0" {
  value = "${aws_instance.west_consul_0.private_ip} - ${aws_instance.west_consul_0.public_ip}"
}

output "west_consul_1" {
  value = "${aws_instance.west_consul_1.private_ip} - ${aws_instance.west_consul_1.public_ip}"
}

output "west_consul_2" {
  value = "${aws_instance.west_consul_2.private_ip} - ${aws_instance.west_consul_2.public_ip}"
}
