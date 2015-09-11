#--------------------------------------------------------------
# AWS
#--------------------------------------------------------------

region = "us-east-1"

#--------------------------------------------------------------
# General
#--------------------------------------------------------------

atlas_username    = "YOUR_ATLAS_USERNAME"
atlas_environment = "example-01"
name              = "example"
cert_name         = "example"
key_name          = "example"

#--------------------------------------------------------------
# Access
#--------------------------------------------------------------

iam_admins = "user1,user2"

#--------------------------------------------------------------
# AWS Artifacts
#--------------------------------------------------------------

aws_consul_latest_name      = "aws-ubuntu-consul"
aws_consul_pinned_name      = "aws-ubuntu-consul"
aws_consul_pinned_version   = "latest"
aws_vault_latest_name       = "aws-ubuntu-vault"
aws_vault_pinned_name       = "aws-ubuntu-vault"
aws_vault_pinned_version    = "latest"
aws_rabbitmq_latest_name    = "aws-ubuntu-rabbitmq"
aws_rabbitmq_pinned_name    = "aws-ubuntu-rabbitmq"
aws_rabbitmq_pinned_version = "latest"
aws_web_latest_name         = "aws-windows-web"
aws_web_pinned_name         = "aws-windows-web"
aws_web_pinned_version      = "latest"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

vpc_cidr          = "10.139.0.0/16"
private_subnets   = "10.139.1.0/24,10.139.2.0/24,10.139.3.0/24"
ephemeral_subnets = "10.139.11.0/24,10.139.12.0/24,10.139.13.0/24"
public_subnets    = "10.139.101.0/24,10.139.102.0/24,10.139.103.0/24"

# Subnets can currently only be created in the following availability
# zones: us-east-1a, us-east-1b, us-east-1d, us-east-1e.
azs = "us-east-1b,us-east-1d,us-east-1e"

# Bastion
bastion_instance_type = "t2.micro"

# NAT
nat_instance_type = "t2.micro"

# OpenVPN
openvpn_instance_type = "t2.micro"
openvpn_ami           = "ami-b62d20de"
openvpn_admin_user    = "vpnadmin"
openvpn_admin_pw      = "sdEKxN2dwDK4FziU6QEKjUeegcC8ZfBYA3fzMgqXfocgQvWGRw"
openvpn_cidr          = "172.27.139.0/24"

# DNS
domain = "awsexample.com"

#--------------------------------------------------------------
# Data
#--------------------------------------------------------------

# Postgres
db_name           = "example"
db_username       = "exampleuser"
db_password       = "examplepass"
db_engine         = "postgres"
db_engine_version = "9.4.1"
db_port           = "5432"

db_az                      = "us-east-1b"
db_multi_az                = "false"
db_instance_type           = "db.t2.micro"
db_storage_gbs             = "100"
db_iops                    = "1000"
db_storage_type            = "gp2"
db_apply_immediately       = "true"
db_publicly_accessible     = "false"
db_storage_encrypted       = "false"
db_maintenance_window      = "mon:04:03-mon:04:33"
db_backup_retention_period = "7"
db_backup_window           = "10:19-10:49"

# Redis
redis_instance_type = "cache.m1.small"
redis_port = "6379"
redis_initial_cached_nodes = "1"
redis_apply_immediately = "true"
redis_maintenance_window = "mon:05:00-mon:06:00"

# Consul
consul_ips           = "10.139.1.4,10.139.2.4,10.139.3.4"
consul_instance_type = "t2.micro"

# Vault
vault_count         = "2"
vault_instance_type = "t2.micro"

# RabbitMQ
rabbitmq_count         = "1"
rabbitmq_instance_type = "t2.micro"
# rabbitmq_blue_nodes = "1"
# rabbitmq_green_nodes = "0"
rabbitmq_username = "exampleuser"
rabbitmq_password = "3PdgvsyukoG8y39G2rMD"
rabbitmq_vhost = "example"

#--------------------------------------------------------------
# App
#--------------------------------------------------------------

web_instance_type = "t2.micro"
web_blue_nodes = "2"
web_green_nodes = "0"
