resource "aws_key_pair" "main" {
  key_name   = "${var.environment_name}"
  public_key = "${file(module.shared.public_key_path)}"
}
