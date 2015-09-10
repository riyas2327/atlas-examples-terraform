resource "template_file" "consul_update_east" {
  filename = "${module.shared.path}/consul/userdata/consul_update_multiregion.sh.tpl"

  vars {
    region                  = "${var.region}"
    atlas_token             = "${var.atlas_token}"
    atlas_organization      = "${var.atlas_organization}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }
}

//
// Consul Client
//
resource "aws_instance" "consul_client" {
  provider               = "aws.east"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_client.metadata_full.region-us-east-1}"
  key_name               = "${aws_key_pair.east_main.key_name}"

  user_data              = "${template_file.consul_update_east.rendered}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul_client.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "consul_client"
  }

}

//
// Consul Servers
//
resource "aws_instance" "consul_0" {
  provider               = "aws.east"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_multiregion.metadata_full.region-us-east-1}"
  key_name               = "${aws_key_pair.east_main.key_name}"

  user_data              = "${template_file.consul_update_east.rendered}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}","${aws_security_group.east_consul_wan.id}"]
  subnet_id              = "${aws_subnet.subnet_a.id}"

  tags {
    Name = "consul_0"
  }

}

resource "aws_instance" "consul_1" {
  provider               = "aws.east"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_multiregion.metadata_full.region-us-east-1}"
  key_name               = "${aws_key_pair.east_main.key_name}"

  user_data              = "${template_file.consul_update_east.rendered}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}","${aws_security_group.east_consul_wan.id}"]
  subnet_id              = "${aws_subnet.subnet_b.id}"

  tags {
    Name = "consul_1"
  }

}

resource "aws_instance" "consul_2" {
  provider               = "aws.east"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_multiregion.metadata_full.region-us-east-1}"
  key_name               = "${aws_key_pair.east_main.key_name}"

  user_data              = "${template_file.consul_update_east.rendered}"

  vpc_security_group_ids = ["${aws_security_group.default_egress.id}","${aws_security_group.admin_access.id}","${aws_security_group.consul.id}","${aws_security_group.east_consul_wan.id}"]
  subnet_id              = "${aws_subnet.subnet_c.id}"

  tags {
    Name = "consul_2"
  }

}
