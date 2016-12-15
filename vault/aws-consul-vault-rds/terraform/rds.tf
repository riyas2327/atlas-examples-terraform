resource "aws_subnet" "rds" {
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.main.names,count.index)}"
  cidr_block        = "${element(var.vpc_cidrs_rds,count.index)}"

  count = "${length(var.vpc_cidrs_rds)}"

  tags {
    Name = "${var.atlas_environment}-rds"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.atlas_environment}"
  subnet_ids = ["${aws_subnet.rds.0.id}", "${aws_subnet.rds.1.id}"]

  tags {
    Name = "${var.atlas_environment}"
  }
}

resource "aws_db_instance" "main" {
  name                   = "${var.rds_db_name}"
  vpc_security_group_ids = ["${aws_security_group.all.id}"]

  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "9.5.4"
  instance_class       = "db.t2.medium"
  username             = "${var.rds_username_password}"
  password             = "${var.rds_username_password}"
  db_subnet_group_name = "${aws_db_subnet_group.main.id}"
}

variable "rds_username_password" {
  default = "vault123456"
}

variable "rds_db_name" {
  default = "nomadconsulvault"
}

output "rds_address" {
  value = "${aws_db_instance.main.address}"
}
