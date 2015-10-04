//
// INSTANCES
//
resource "aws_key_pair" "spark-poc" {
    key_name = "spark-poc"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw3f97M5BnuAUWtBn0tlFLmHKNWswQmt6rfViIYoKKtQiFY6FW5ORYe1FnsRco7rxSpNnSDAuDjYnEqCYn4dxAxgnqsMHbN4r67rebomp9t6x0+LWjNh36LT9qAMeHiuDrW2AV0Zo8g1eOqjUUzzUmDljUo/o+wq/wAIoG2ML8nsguUJkvmkxufes+RRN8VZ2RWCqTC3QQmPnjiSOeIsxSHlh+0aXJYg28BQe880SV7Dyw1n5O+QrbbKC9cr0NzoFrJr+GNVBNOAYouHVg5fLB4NzY7v+OVvyEmMzukiTrnbompn/+eLv3MZ8ULI1UXyFqpRMC++7d//xkjjyDKlzkMq1euLmkyEcvA5swTGszhxvk/mU5Lfe2NNAKiVvtLm8oGm1q/20d/VsrCulXZC6XPs+zFwcsdZQipOWQMduQtUMJrxCsL9RqJzwwRRTnHJS2NUsuG3XeYwkElJ3pIGB1hP2bRorY9HWjg11loFpQPSrSfqpaHyX2Wg0b+uY9ltoH4TXyAqcCyLCezZhtBzgHMQZP7udHwmuoKPFt/9AUL/t2t2kT7AMl8Ix8p3L2ooj/5rVLNTXfIHy1kqHK6mk2DEKlX+EerFoYZcejegJ8BjtdfjVzlNFZ4Fkf7RUbq+xtvl1Arb7iVntRgDuGyYlGDoLH6Rsen5Txi6KJlk2diQ== cameron@hashicorp.com"
}

resource "template_file" "consul-update" {
    filename = "${path.module}/userdata/consul-update.sh.tpl"

    vars {
        region = "${var.region}"
        atlas_username = "${var.atlas_username}"
        atlas_environment = "${var.atlas_environment}"
        atlas_user_token = "${var.atlas_user_token}"
        consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
    }
}

resource "template_file" "spark-master-start" {
    filename = "${path.module}/userdata/spark-master-start.sh.tpl"

    vars {
        region = "${var.region}"
        atlas_username = "${var.atlas_username}"
        atlas_environment = "${var.atlas_environment}"
        atlas_user_token = "${var.atlas_user_token}"
        consul_bootstrap_expect = "${var.consul_bootstrap_expect}"
    }
}

resource "template_file" "spark-slave-start" {
    filename = "${path.module}/userdata/spark-slave-start.sh.tpl"

    vars {
        region = "${var.region}"
        atlas_username = "${var.atlas_username}"
        atlas_environment = "${var.atlas_environment}"
        atlas_user_token = "${var.atlas_user_token}"
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
    key_name = "${aws_key_pair.spark-poc.key_name}"
    count = "2"

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
    key_name = "${aws_key_pair.spark-poc.key_name}"

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
    key_name = "${aws_key_pair.spark-poc.key_name}"
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

output "spark-example-application" {
  value = <<SPARKEXAMPLE

spark-master-0-address = ${aws_instance.spark-master.0.public_ip}
spark-slave-0-address  = ${aws_instance.spark-slave.0.public_ip}

To view the Spark console, run the command below and then open http://localhost:8080/ in your browser.

    ssh -i ~/.ssh/spark-poc_rsa -L 8080:${aws_instance.spark-master.0.private_ip}:8080 ubuntu@${aws_instance.spark-master.0.public_ip}

To run an example Spark application in your Spark cluster, run the command below.

    ssh -i ~/.ssh/spark-poc_rsa ubuntu@${aws_instance.spark-master.0.public_ip} MASTER=spark://${element(split(".",aws_instance.spark-master.0.private_dns),0)}:7077 /opt/spark/default/bin/run-example SparkPi 10

SPARKEXAMPLE
}
