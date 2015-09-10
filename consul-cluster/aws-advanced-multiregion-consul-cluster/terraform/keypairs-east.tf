resource "aws_key_pair" "east_main" {
  provider   = "aws.east"
  key_name   = "${var.key_name}"
  public_key = "${file(module.shared.public_key_path)}"
}
