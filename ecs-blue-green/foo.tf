variable "blue_version" { }
variable "blue_count"   { }

variable "green_version" { }
variable "green_count"   { }

variable "task_name"   { default = "foo-task" }
variable "task_image"  { default = "foo-image" }
variable "family"      { default = "foo-family" }
variable "volume_name" { default = "foo-storage" }
variable "host_path"   { default = "/ecs/foo-storage" }
variable "type"        { default = "memberOf" }
variable "expression"  { default = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]" }

provider "aws" { }

data "template_file" "blue_task_definition" {
  vars {
    task_name  = "${var.task_name}"
    task_image = "${var.task_image}"
    version    = "${var.blue_version}"
  }

  template = "${file("${path.module}/foo-task-def.tpl")}"
}

module "blue_foo_task_def" {
  source = "./ecs-task-def"

  count       = "${var.blue_count}"
  family      = "${var.family}-blue"
  definitions = "${data.template_file.blue_task_definition.rendered}"
  volume_name = "${var.volume_name}"
  host_path   = "${var.host_path}"
  type        = "${var.type}"
  expression  = "${var.expression}"
}

data "template_file" "green_task_definition" {
  vars {
    task_name  = "${var.task_name}"
    task_image = "${var.task_image}"
    version    = "${var.green_version}"
  }

  template = "${file("${path.module}/foo-task-def.tpl")}"
}

module "green_foo_task_def" {
  source = "./ecs-task-def"

  count       = "${var.green_count}"
  family      = "${var.family}-green"
  definitions = "${data.template_file.green_task_definition.rendered}"
  volume_name = "${var.volume_name}"
  host_path   = "${var.host_path}"
  type        = "${var.type}"
  expression  = "${var.expression}"
}

output "blue_arn"      { value = "${module.blue_foo_task_def.arn}" }
output "blue_family"   { value = "${module.blue_foo_task_def.family}" }
output "blue_revision" { value = "${module.blue_foo_task_def.revision}" }

output "green_arn"      { value = "${module.green_foo_task_def.arn}" }
output "green_family"   { value = "${module.green_foo_task_def.family}" }
output "green_revision" { value = "${module.green_foo_task_def.revision}" }
