resource "template_file" "west_consul_update" {
  filename = "${module.shared.path}/consul/userdata/consul_update_multiregion.sh.tpl"

  vars {
    region                  = "${var.region_west}"
    atlas_token             = "${var.atlas_token}"
    atlas_organization      = "${var.atlas_organization}"
    atlas_environment       = "${var.atlas_environment}"
    consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
  }
}

//
// Consul Client
//
resource "aws_instance" "west_consul_client" {
  provider               = "aws.west"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_client.metadata_full.region-us-west-2}"
  key_name               = "${aws_key_pair.west_main.key_name}"

  user_data              = "${template_file.west_consul_update.rendered}"

  vpc_security_group_ids = ["${aws_security_group.west_default_egress.id}","${aws_security_group.west_admin_access.id}","${aws_security_group.west_consul_client.id}"]
  subnet_id              = "${aws_subnet.west_subnet_a.id}"

  tags {
    Name = "consul_client"
  }

}

//
// Consul Servers
//
resource "aws_instance" "west_consul_0" {
  provider               = "aws.west"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_multiregion.metadata_full.region-us-west-2}"
  key_name               = "${aws_key_pair.west_main.key_name}"

  user_data              = "${template_file.west_consul_update.rendered}"

  vpc_security_group_ids = ["${aws_security_group.west_default_egress.id}","${aws_security_group.west_admin_access.id}","${aws_security_group.west_consul.id}","${aws_security_group.west_consul_wan.id}"]
  subnet_id              = "${aws_subnet.west_subnet_a.id}"

  tags {
    Name = "consul_0"
  }

}

resource "aws_instance" "west_consul_1" {
  provider               = "aws.west"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_multiregion.metadata_full.region-us-west-2}"
  key_name               = "${aws_key_pair.west_main.key_name}"

  user_data              = "${template_file.west_consul_update.rendered}"

  vpc_security_group_ids = ["${aws_security_group.west_default_egress.id}","${aws_security_group.west_admin_access.id}","${aws_security_group.west_consul.id}","${aws_security_group.west_consul_wan.id}"]
  subnet_id              = "${aws_subnet.west_subnet_b.id}"

  tags {
    Name = "consul_1"
  }

}

resource "aws_instance" "west_consul_2" {
  provider               = "aws.west"
  instance_type          = "${var.instance_type}"
  ami                    = "${atlas_artifact.consul_multiregion.metadata_full.region-us-west-2}"
  key_name               = "${aws_key_pair.west_main.key_name}"

  user_data              = "${template_file.west_consul_update.rendered}"

  vpc_security_group_ids = ["${aws_security_group.west_default_egress.id}","${aws_security_group.west_admin_access.id}","${aws_security_group.west_consul.id}","${aws_security_group.west_consul_wan.id}"]
  subnet_id              = "${aws_subnet.west_subnet_c.id}"

  tags {
    Name = "consul_2"
  }

}
