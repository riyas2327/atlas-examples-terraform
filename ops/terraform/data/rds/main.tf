variable "name" { default = "postgres" }
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnet_ids" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "engine" { default = "postgres" }
variable "engine_version" { default = "9.4.1" }
variable "port" { default = "5432"}

variable "m_az" {}
variable "m_multi_az" {}
variable "m_instance_type" {}
variable "m_storage_gbs" { default = "100" }
variable "m_iops" { default = "1000" }
variable "m_storage_type" { default = "io1" }
variable "m_apply_immediately" { default = false }
variable "m_publicly_accessible" { default = false }
variable "m_storage_encrypted" { default = false }
variable "m_maintenance_window" { default = "mon:04:03-mon:04:33" }
variable "m_backup_retention_period" { default = 7 }
variable "m_backup_window" { default = "10:19-10:49" }

variable "r_az" {}
variable "r_multi_az" {}
variable "r_instance_type" {}
variable "r_storage_gbs" { default = "100" }
variable "r_iops" { default = "1000" }
variable "r_storage_type" { default = "gp2"}
variable "r_apply_immediately" { default = false }
variable "r_publicly_accessible" { default = false }
variable "r_storage_encrypted" { default = false }
variable "r_maintenance_window" { default = "mon:04:03-mon:04:33" }
variable "r_backup_retention_period" { default = 7 }
variable "r_backup_window" { default = "10:19-10:49" }

resource "aws_security_group" "rds" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for RDS"

  tags { Name = "${var.name}" }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}"
  subnet_ids  = ["${split(",", var.subnet_ids)}"]
  description = "Subnet group for RDS"
}

resource "aws_db_instance" "master" {
  identifier     = "${var.name}"
  name           = "${var.db_name}"
  username       = "${var.username}"
  password       = "${var.password}"
  engine         = "${var.engine}"
  engine_version = "${var.engine_version}"
  port           = "${var.port}"

  # availability_zone       = "${var.m_az}"
  multi_az                = "${var.m_multi_az}"
  instance_class          = "${var.m_instance_type}"
  allocated_storage       = "${var.m_storage_gbs}"
  iops                    = "${var.m_iops}"
  storage_type            = "${var.m_storage_type}"
  apply_immediately       = "${var.m_apply_immediately}"
  publicly_accessible     = "${var.m_publicly_accessible}"
  storage_encrypted       = "${var.m_storage_encrypted}"
  maintenance_window      = "${var.m_maintenance_window}"
  backup_retention_period = "${var.m_backup_retention_period}"
  backup_window           = "${var.m_backup_window}"

  # final_snapshot_identifier = "${var.name}"
  # snapshot_identifier     = "EXISTING_SNAPSHOT_ID"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.rds.id}"
}

resource "aws_db_instance" "replica" {
  identifier     = "${var.name}-replica"
  name           = "${var.db_name}"
  username       = "${var.username}"
  password       = "${var.password}"
  engine         = "${var.engine}"
  engine_version = "${var.engine_version}"
  port           = "${var.port}"

  # availability_zone       = "${var.r_az}"
  multi_az                = "${var.r_multi_az}"
  instance_class          = "${var.r_instance_type}"
  allocated_storage       = "${var.r_storage_gbs}"
  # iops                    = "${var.r_iops}"
  storage_type            = "${var.r_storage_type}"
  apply_immediately       = "${var.r_apply_immediately}"
  publicly_accessible     = "${var.r_publicly_accessible}"
  storage_encrypted       = "${var.r_storage_encrypted}"
  maintenance_window      = "${var.r_maintenance_window}"
  # backup_retention_period = "${var.r_backup_retention_period}"
  # backup_window           = "${var.r_backup_window}"

  # final_snapshot_identifier = "${var.name}"
  replicate_source_db       = "${aws_db_instance.master.id}"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.rds.id}"
}

output "endpoint" { value = "${aws_db_instance.master.endpoint}" }
output "username" { value = "${var.username}" }
output "password" { value = "${var.password}" }
