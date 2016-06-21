resource "aws_key_pair" "east_main" {
  provider   = "aws.east"
  key_name   = "${var.key_name}"
  public_key = "${var.key_data_public}"
}
