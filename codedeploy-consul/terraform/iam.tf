//
// Instance Profile for CodeDeploy
//
resource "aws_iam_instance_profile" "codedeploy" {
  name  = "CodeDeployDemo-EC2-Instance-Profile"
  roles = ["${aws_iam_role.codedeploy_instance.name}"]
}

resource "aws_iam_policy_attachment" "codedeploy_instance" {
  name       = "codedeploy"
  roles      = ["${aws_iam_role.codedeploy_instance.name}"]
  policy_arn = "${aws_iam_policy.codedeploy_instance.arn}"
}

resource "aws_iam_policy" "codedeploy_instance" {
  name   = "CodeDeployDemo-EC2-Permissions"
  policy = "${file("${module.shared.path}/codedeploy-agent/iam/instance-profile-permissions.json")}"
}

resource "aws_iam_role" "codedeploy_instance" {
  name               = "CodeDeployDemo-EC2"
  assume_role_policy = "${file("${module.shared.path}/codedeploy-agent/iam/instance-profile-trust.json")}"
}
