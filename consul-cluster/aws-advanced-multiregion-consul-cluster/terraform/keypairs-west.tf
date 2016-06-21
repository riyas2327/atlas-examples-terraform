resource "aws_key_pair" "west_main" {
  provider   = "aws.west"
  key_name   = "${var.key_name}"
  public_key = "${var.key_data_public}"
}
