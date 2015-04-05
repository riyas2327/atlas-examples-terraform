provider "aws" {
    access_key = ""
    secret_key = ""
    region = "us-east-1"
}

resource "atlas_artifact" "web" {
  name = "<username>/rails-aws"
  type = "aws.ami"
}

resource "aws_elb" "web" {
    name = "rails-elb"

    # The same availability zone as our instances
    availability_zones = ["${aws_instance.web.*.availability_zone}"]

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 5
      target = "TCP:80"
      interval = 10
    }

    # The instances are registered automatically
    instances = ["${aws_instance.web.*.id}"]

}

resource "aws_security_group" "allow_all" {
  name = "rails-allow_all"
    description = "Allow all inbound traffic"

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web" {
    instance_type = "t2.micro"
    ami = "${atlas_artifact.web.metadata_full.region-us-east-1}"
    security_groups = ["${aws_security_group.allow_all.name}"]
    key_name = "${aws_key_pair.debugging.key_name}"

    # This will create 1 instances
    count = 1

    security_groups = ["${aws_security_group.allow_ssh.id}"]
}


