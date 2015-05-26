provider "atlas" {
  token = "ATLAS_TOKEN_HERE"
}

provider "aws" {
  access_key = "ACCESS_KEY_HERE"
  secret_key = "SECRET_KEY_HERE"
  region = "us-east-1"
}

resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all inbound traffic"

  tags {
    Name = "allow_all"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  instance_type = "t1.micro"
  ami = "ami-408c7f28"
  security_groups = ["${aws_security_group.allow_all.name}"]

  tags {
    Name = "web_${count.index+1}"
  }

  # This will create 2 instances
  count = 2
}

resource "aws_elb" "web" {
  name = "terraform-example-elb"

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

  security_groups = ["${aws_security_group.allow_all.id}"]

  # The instances are registered automatically
  instances = ["${aws_instance.web.*.id}"]
}
