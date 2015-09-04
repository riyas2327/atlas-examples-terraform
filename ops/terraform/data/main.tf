variable "name" {}
variable "azs" {}
variable "key_name" {}
variable "key_path" {}
variable "vpc_id" {}
variable "vpc_cidr" {}

variable "private_subnet_ids" {}
variable "ephemeral_subnet_ids" {}
variable "public_subnet_ids" {}

variable "consul_server_user_data" {}
variable "consul_client_user_data" {}
variable "vault_user_data" {}
variable "atlas_username" {}
variable "atlas_environment" {}
variable "atlas_token" {}

variable "pg_name" {}
variable "pg_username" {}
variable "pg_password" {}
variable "pg_port" {}

variable "pg_m_az" {}
variable "pg_m_multi_az" {}
variable "pg_m_instance_type" {}
variable "pg_m_storage_gbs" {}
variable "pg_m_iops" {}
variable "pg_m_storage_type" {}
variable "pg_m_apply_immediately" {}
variable "pg_m_publicly_accessible" {}
variable "pg_m_storage_encrypted" {}
variable "pg_m_maintenance_window" {}
variable "pg_m_backup_retention_period" {}
variable "pg_m_backup_window" {}

variable "pg_r_az" {}
variable "pg_r_multi_az" {}
variable "pg_r_instance_type" {}
variable "pg_r_storage_gbs" {}
variable "pg_r_iops" {}
variable "pg_r_storage_type" {}
variable "pg_r_apply_immediately" {}
variable "pg_r_publicly_accessible" {}
variable "pg_r_storage_encrypted" {}
variable "pg_r_maintenance_window" {}
variable "pg_r_backup_retention_period" {}
variable "pg_r_backup_window" {}

variable "redis_instance_type" {}
variable "redis_port" {}
variable "redis_initial_cached_nodes" {}
variable "redis_apply_immediately" {}
variable "redis_maintenance_window" {}

variable "rabbitmq_amis" {}
variable "rabbitmq_instance_type" {}
variable "rabbitmq_count" {}
variable "rabbitmq_username" {}
variable "rabbitmq_password" {}
variable "rabbitmq_vhost" {}

variable "ssl_cert_name" {}
variable "ssl_cert_crt" {}
variable "ssl_cert_key" {}
variable "bastion_host" {}
variable "bastion_user" {}

variable "consul_amis" {}
variable "consul_ips" {}
variable "consul_instance_type" {}

variable "vault_amis" {}
variable "vault_instance_type" {}
variable "vault_count" {}

module "rds_postgres" {
  source = "./rds"

  name       = "${var.name}-postgres"
  vpc_id     = "${var.vpc_id}"
  vpc_cidr   = "${var.vpc_cidr}"
  subnet_ids = "${var.private_subnet_ids}"
  db_name    = "${var.pg_name}"
  username   = "${var.pg_username}"
  password   = "${var.pg_password}"
  port       = "${var.pg_port}"

  m_az                      = "${var.pg_m_az}"
  m_multi_az                = "${var.pg_m_multi_az}"
  m_instance_type           = "${var.pg_m_instance_type}"
  m_storage_gbs             = "${var.pg_m_storage_gbs}"
  m_iops                    = "${var.pg_m_iops}"
  m_storage_type            = "${var.pg_m_storage_type}"
  m_apply_immediately       = "${var.pg_m_apply_immediately}"
  m_publicly_accessible     = "${var.pg_m_publicly_accessible}"
  m_storage_encrypted       = "${var.pg_m_storage_encrypted}"
  m_maintenance_window      = "${var.pg_m_maintenance_window}"
  m_backup_retention_period = "${var.pg_m_backup_retention_period}"
  m_backup_window           = "${var.pg_m_backup_window}"

  r_az                      = "${var.pg_r_az}"
  r_multi_az                = "${var.pg_r_multi_az}"
  r_instance_type           = "${var.pg_r_instance_type}"
  r_storage_gbs             = "${var.pg_r_storage_gbs}"
  r_iops                    = "${var.pg_r_iops}"
  r_storage_type            = "${var.pg_r_storage_type}"
  r_apply_immediately       = "${var.pg_r_apply_immediately}"
  r_publicly_accessible     = "${var.pg_r_publicly_accessible}"
  r_storage_encrypted       = "${var.pg_r_storage_encrypted}"
  r_maintenance_window      = "${var.pg_r_maintenance_window}"
  r_backup_retention_period = "${var.pg_r_backup_retention_period}"
  r_backup_window           = "${var.pg_r_backup_window}"
}

module "ec_redis" {
  source = "./elasticache"

  name                 = "${var.name}-redis"
  vpc_id               = "${var.vpc_id}"
  vpc_cidr             = "${var.vpc_cidr}"
  subnet_ids           = "${var.ephemeral_subnet_ids}"
  instance_type        = "${var.redis_instance_type}"
  port                 = "${var.redis_port}"
  initial_cached_nodes = "${var.redis_initial_cached_nodes}"
  apply_immediately    = "${var.redis_apply_immediately}"
  maintenance_window   = "${var.redis_maintenance_window}"
}

module "rabbitmq" {
  source = "./rabbitmq"

  name          = "${var.name}-rabbitmq"
  vpc_id        = "${var.vpc_id}"
  vpc_cidr      = "${var.vpc_cidr}"
  amis          = "${var.rabbitmq_amis}"
  instance_type = "${var.rabbitmq_instance_type}"
  count         = "${var.rabbitmq_count}"
  subnet_ids    = "${var.private_subnet_ids}"
  key_name      = "${var.key_name}"
  key_path      = "${var.key_path}"
  bastion_host  = "${var.bastion_host}"
  bastion_user  = "${var.bastion_user}"

  consul_client_user_data = "${var.consul_client_user_data}"
  atlas_username          = "${var.atlas_username}"
  atlas_environment       = "${var.atlas_environment}"
  atlas_token             = "${var.atlas_token}"

  username = "${var.rabbitmq_username}"
  password = "${var.rabbitmq_password}"
  vhost    = "${var.rabbitmq_vhost}"
}

module "consul" {
  source = "./consul"

  name          = "${var.name}-consul"
  vpc_id        = "${var.vpc_id}"
  vpc_cidr      = "${var.vpc_cidr}"
  amis          = "${var.consul_amis}"
  static_ips    = "${var.consul_ips}"
  instance_type = "${var.consul_instance_type}"
  key_name      = "${var.key_name}"
  subnet_ids    = "${var.private_subnet_ids}"

  consul_server_user_data = "${var.consul_server_user_data}"
  atlas_username          = "${var.atlas_username}"
  atlas_environment       = "${var.atlas_environment}"
  atlas_token             = "${var.atlas_token}"

  key_path      = "${var.key_path}"
  bastion_host  = "${var.bastion_host}"
  bastion_user  = "${var.bastion_user}"
}

module "vault" {
  source = "./vault"

  name               = "${var.name}-vault"
  vpc_id             = "${var.vpc_id}"
  vpc_cidr           = "${var.vpc_cidr}"
  azs                = "${var.azs}"
  private_subnet_ids = "${var.private_subnet_ids}"
  public_subnet_ids  = "${var.public_subnet_ids}"
  key_name           = "${var.key_name}"
  key_path           = "${var.key_path}"
  amis               = "${var.vault_amis}"
  instance_type      = "${var.vault_instance_type}"
  count              = "${var.vault_count}"
  ssl_cert_name      = "${var.ssl_cert_name}"
  ssl_cert_crt       = "${var.ssl_cert_crt}"
  ssl_cert_key       = "${var.ssl_cert_key}"
  bastion_host       = "${var.bastion_host}"
  bastion_user       = "${var.bastion_user}"

  vault_user_data   = "${var.vault_user_data}"
  atlas_username    = "${var.atlas_username}"
  atlas_environment = "${var.atlas_environment}"
  atlas_token       = "${var.atlas_token}"
  consul_ips        = "${var.consul_ips}"
}

output "pg_endpoint" { value = "${module.rds_postgres.endpoint}" }
output "pg_username" { value = "${module.rds_postgres.username}" }
output "pg_password" { value = "${module.rds_postgres.password}" }

output "redis_host"     { value = "${module.ec_redis.host}" }
output "redis_port"     { value = "${module.ec_redis.port}" }
output "redis_password" { value = "${module.ec_redis.password}" }

output "rabbitmq_host"        { value = "${module.rabbitmq.host}" }
output "rabbitmq_private_ips" { value = "${module.rabbitmq.private_ips}" }
output "rabbitmq_port"        { value = "${module.rabbitmq.port}" }
output "rabbitmq_username"    { value = "${module.rabbitmq.username}" }
output "rabbitmq_password"    { value = "${module.rabbitmq.password}" }
output "rabbitmq_vhost"       { value = "${module.rabbitmq.vhost}" }

output "consul_ips" { value = "${module.consul.consul_ips}" }

output "vault_dns_name"    { value = "${module.vault.dns_name}" }
output "vault_private_ips" { value = "${module.vault.private_ips}" }

output "remote_commands" {
  value = <<COMMANDS
${module.rabbitmq.remote_commands}
COMMANDS
}
