//
// Variables
//
variable "vpc_cidr"    {}
variable "subnet_cidr" {}

//
// Outputs
//
output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "subnet_id" {
    value = "${aws_subnet.main.id}"
}
