resource "template_file" "consul-update" {
    filename = "${path.module}/userdata/consul-update.sh.tpl"

    vars {
        region                  = "${var.region}"
        atlas_username          = "${var.atlas_username}"
        atlas_environment       = "${var.atlas_environment}"
        atlas_token             = "${var.atlas_token}"
        consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
    }
}

resource "template_file" "spark-master-start" {
    filename = "${path.module}/userdata/spark-master-start.sh.tpl"

    vars {
      region                  = "${var.region}"
      atlas_username          = "${var.atlas_username}"
      atlas_environment       = "${var.atlas_environment}"
      atlas_token             = "${var.atlas_token}"
      consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
    }
}

resource "template_file" "spark-slave-start" {
    filename = "${path.module}/userdata/spark-slave-start.sh.tpl"

    vars {
      region                  = "${var.region}"
      atlas_username          = "${var.atlas_username}"
      atlas_environment       = "${var.atlas_environment}"
      atlas_token             = "${var.atlas_token}"
      consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
    }
}

resource "atlas_artifact" "spark-consul" {
    name = "${var.atlas_username}/spark-consul"
    type = "amazon.image"
}

resource "atlas_artifact" "spark-master" {
    name = "${var.atlas_username}/spark-master"
    type = "amazon.image"
}

resource "atlas_artifact" "spark-slave" {
    name = "${var.atlas_username}/spark-slave"
    type = "amazon.image"
}

resource "aws_instance" "consul" {
    instance_type = "${var.instance_type}"
    ami = "${atlas_artifact.spark-consul.metadata_full.region-us-east-1}"
    key_name = "${aws_key_pair.main.key_name}"
    count = "3"

    user_data = "${template_file.consul-update.rendered}"

    vpc_security_group_ids = ["${aws_security_group.admin-access.id}","${aws_security_group.spark-master.id}"]
    subnet_id = "${module.vpc.subnet_id}"

    tags {
        Name = "${format("consul-%04d", count.index)}"
    }

}

resource "aws_instance" "spark-master" {
    instance_type = "${var.instance_type}"
    ami = "${atlas_artifact.spark-master.metadata_full.region-us-east-1}"
    key_name = "${aws_key_pair.main.key_name}"

    user_data = "${template_file.spark-master-start.rendered}"

    vpc_security_group_ids = ["${aws_security_group.admin-access.id}","${aws_security_group.spark-master.id}"]
    subnet_id = "${module.vpc.subnet_id}"

    tags {
        Name = "${format("spark-master-%04d", count.index)}"
    }
}

resource "aws_instance" "spark-slave" {
    instance_type = "${var.instance_type}"
    ami = "${atlas_artifact.spark-slave.metadata_full.region-us-east-1}"
    key_name = "${aws_key_pair.main.key_name}"
    count = "${var.spark_slave_count}"

    user_data = "${template_file.spark-slave-start.rendered}"

    vpc_security_group_ids = ["${aws_security_group.admin-access.id}","${aws_security_group.spark-slave.id}"]
    subnet_id = "${module.vpc.subnet_id}"

    // slave instances explicitly depend on the master
    depends_on = ["aws_instance.spark-master"]

    tags {
        Name = "${format("spark-slave-%04d", count.index)}"
    }
}
