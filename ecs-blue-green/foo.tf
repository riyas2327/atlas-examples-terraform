variable "blue_version" { }
variable "blue_count"   { }
# variable "blue_pct"     { }

variable "green_version" { }
variable "green_count"   { }
# variable "green_pct"     { }

# variable "final_count" { default = "5" }
variable "task_name"   { default = "foo-name" }
variable "task_image"  { default = "foo-image" }
variable "family"      { default = "foo-family" }
variable "volume_name" { default = "foo-storage" }
variable "host_path"   { default = "/ecs/foo-storage" }
variable "type"        { default = "memberOf" }
variable "expression"  { default = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]" }

provider "aws" { }

data "template_file" "blue_task_definitions" {
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
  # count       = "${ceil((var.blue_pct / 100.0) * var.final_count)}" # Count defined by percent of final_count
  family      = "${var.family}-blue"
  definitions = "${data.template_file.blue_task_definitions.rendered}"
  volume_name = "${var.volume_name}"
  host_path   = "${var.host_path}"
  type        = "${var.type}"
  expression  = "${var.expression}"
}

data "template_file" "green_task_definitions" {
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
  # count       = "${ceil((var.green_pct / 100.0) * var.final_count)}" # Count defined by percent of final_count
  family      = "${var.family}-green"
  definitions = "${data.template_file.green_task_definitions.rendered}"
  volume_name = "${var.volume_name}"
  host_path   = "${var.host_path}"
  type        = "${var.type}"
  expression  = "${var.expression}"
}

output "blue_arns"      { value = "${module.blue_foo_task_def.arns}" }
output "blue_families"  { value = "${module.blue_foo_task_def.families}" }
output "blue_revisions" { value = "${module.blue_foo_task_def.revisions}" }

output "green_arns"      { value = "${module.green_foo_task_def.arns}" }
output "green_families"  { value = "${module.green_foo_task_def.families}" }
output "green_revisions" { value = "${module.green_foo_task_def.revisions}" }
