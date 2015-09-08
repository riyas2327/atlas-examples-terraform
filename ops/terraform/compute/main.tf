variable "name" {}
variable "azs" {}
variable "vpc_cidr" {}
variable "key_name" {}
variable "key_path" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "ssl_cert_crt" {}
variable "ssl_cert_key" {}
variable "bastion_host" {}
variable "bastion_user" {}
variable "domain" {}
variable "email_from" {}
variable "smtp_id" {}
variable "smtp_password" {}

variable "consul_client_user_data" {}
variable "atlas_username" {}
variable "atlas_environment" {}
variable "atlas_token" {}
variable "consul_ips" {}

variable "pg_endpoint" {}
variable "pg_username" {}
variable "pg_password" {}
variable "pg_name" {}

variable "redis_host" {}
variable "redis_port" {}
variable "redis_password" {}

variable "rabbitmq_host" {}
variable "rabbitmq_port" {}
variable "rabbitmq_username" {}
variable "rabbitmq_password" {}
variable "rabbitmq_vhost" {}

variable "vault_private_ip" {}
variable "vault_domain" {}

variable "statsite_address" {}

variable "app_instance_type" {}
variable "app_blue_ami" {}
variable "app_blue_nodes" {}
variable "app_green_ami" {}
variable "app_green_nodes" {}

module "app" {
  source = "./app"

  name               = "${var.name}-app"
  key_name           = "${var.key_name}"
  key_path           = "${var.key_path}"
  azs                = "${var.azs}"
  vpc_id             = "${var.vpc_id}"
  vpc_cidr           = "${var.vpc_cidr}"
  public_subnet_ids  = "${var.public_subnet_ids}"
  private_subnet_ids = "${var.private_subnet_ids}"
  ssl_cert_crt       = "${var.ssl_cert_crt}"
  ssl_cert_key       = "${var.ssl_cert_key}"
  domain             = "${var.domain}"

  consul_client_user_data = "${var.consul_client_user_data}"
  atlas_username          = "${var.atlas_username}"
  atlas_environment       = "${var.atlas_environment}"
  atlas_token             = "${var.atlas_token}"
  consul_ips              = "${var.consul_ips}"

  pg_endpoint = "${var.pg_endpoint}"
  pg_username = "${var.pg_username}"
  pg_password = "${var.pg_password}"
  pg_name     = "${var.pg_name}"

  redis_host     = "${var.redis_host}"
  redis_port     = "${var.redis_port}"
  redis_password = "${var.redis_password}"

  rabbitmq_host     = "${var.rabbitmq_host}"
  rabbitmq_port     = "${var.rabbitmq_port}"
  rabbitmq_username = "${var.rabbitmq_username}"
  rabbitmq_password = "${var.rabbitmq_password}"
  rabbitmq_vhost    = "${var.rabbitmq_vhost}"

  bastion_host     = "${var.bastion_host}"
  bastion_user     = "${var.bastion_user}"
  vault_private_ip = "${var.vault_private_ip}"
  vault_domain     = "${var.vault_domain}"

  statsite_address = "${var.statsite_address}"

  instance_type = "${var.app_instance_type}"
  blue_ami      = "${var.app_blue_ami}"
  blue_nodes    = "${var.app_blue_nodes}"
  green_ami     = "${var.app_green_ami}"
  green_nodes   = "${var.app_green_nodes}"
}

output "app_dns_name"   { value = "${module.app.dns_name}" }
output "app_zone_id"    { value = "${module.app.zone_id}" }

output "remote_commands" {
  value = <<COMMANDS
${module.app.remote_commands}
COMMANDS
}
