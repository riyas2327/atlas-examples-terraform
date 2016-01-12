resource "aws_codedeploy_app" "sampleapp" {
  name = "SampleApp_Linux"
}

resource "aws_codedeploy_deployment_group" "foo" {
  deployment_group_name = "SampleApp_Linux"

  app_name              = "${aws_codedeploy_app.sampleapp.name}"
  service_role_arn      = "${aws_iam_role.codedeploy_service_role.arn}"

  ec2_tag_filter {
    type  = "KEY_AND_VALUE"
    key   = "codedeploy"
    value = "true"
  }
}
