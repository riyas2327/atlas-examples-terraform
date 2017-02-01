variable "count"       { }
variable "family"      { }
variable "definitions" { }
variable "volume_name" { }
variable "host_path"   { }
variable "type"        { }
variable "expression"  { }

resource "aws_ecs_task_definition" "def" {
  count  = "${var.count}"
  family = "${var.family}"

  container_definitions = "${var.definitions}"

  volume {
    name      = "${var.volume_name}"
    host_path = "${var.host_path}"
  }

  placement_constraints {
    type       = "${var.type}"
    expression = "${var.expression}"
  }
}

output "arn"      { value = "${aws_ecs_task_definition.def.arn}" }
output "family"   { value = "${aws_ecs_task_definition.def.family}" }
output "revision" { value = "${aws_ecs_task_definition.def.revision}" }
