variable "name" { default = "route53" }
variable "domain" {}
variable "region" {}
variable "vpc_id" {}
variable "main_a_records" {}
variable "main_mx_records" {}
variable "main_txt_gsv_records" {}
variable "www_cname" {}
variable "vpn_ips" {}

variable "app_dns_name" {}
variable "app_zone_id" {}
variable "forms_dns_name" {}
variable "forms_zone_id" {}

resource "aws_route53_delegation_set" "mod" {
  reference_name = "${var.name}"
}

resource "aws_route53_zone" "main" {
  name        = "${var.domain}"
  comment     = "${var.name}.main"

  delegation_set_id = "${aws_route53_delegation_set.mod.id}"

  tags { Name = "${var.name}.main" }
}

resource "aws_route53_record" "main_a" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domain}"
  type = "A"
  ttl = "300"

  records = ["${split(",", var.main_a_records)}"]
}

resource "aws_route53_record" "main_mx" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domain}"
  type = "MX"
  ttl = "259200"

  records = ["${split(",", var.main_mx_records)}"]
}

resource "aws_route53_record" "main_txt_google" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domain}"
  type = "TXT"
  ttl = "3600"

  records = ["${split(",", var.main_txt_gsv_records)}"]
}

resource "aws_route53_record" "www_cname" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "www.${var.domain}"
  type = "CNAME"
  ttl = "300"
  records = ["${var.www_cname}"]
}

resource "aws_route53_record" "vpn_a" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "vpn.${var.domain}"
  type = "A"
  ttl = "300"
  records = ["${var.vpn_ips}"]
}

resource "aws_route53_zone" "staging" {
  name        = "staging.${var.domain}"
  comment     = "${var.name}.staging"

  tags { Name = "${var.name}.staging" }
}

resource "aws_route53_record" "staging_ns" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "staging.${var.domain}"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.staging.name_servers.0}",
    "${aws_route53_zone.staging.name_servers.1}",
    "${aws_route53_zone.staging.name_servers.2}",
    "${aws_route53_zone.staging.name_servers.3}"
  ]
}

resource "aws_route53_zone" "main2" {
  name        = "${var.domain}2"
  comment     = "${var.name}.main2"

  delegation_set_id = "${aws_route53_delegation_set.mod.id}"

  tags { Name = "${var.name}.main2" }
}

resource "aws_route53_record" "main2_a" {
  zone_id = "${aws_route53_zone.main2.zone_id}"
  name = "${var.domain}2"
  type = "A"
  ttl = "300"

  records = ["${split(",", var.main_a_records)}"]
}

/*
resource "aws_route53_health_check" "app" {
  fqdn = "app.${var.domain}"
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "5"
  request_interval = "30"

  tags { Name = "${var.name}.app" }
}
*/

resource "aws_route53_record" "app" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "app.${var.domain}"
  type    = "A"

  # health_check_id = "${aws_route53_health_check.app.id}"

  alias {
    name = "${var.app_dns_name}"
    zone_id = "${var.app_zone_id}"
    evaluate_target_health = true
  }
}

/*
resource "aws_route53_health_check" "forms" {
  fqdn = "forms.${var.domain}"
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "5"
  request_interval = "30"

  tags { Name = "${var.name}.forms" }
}
*/

resource "aws_route53_record" "forms" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "forms.${var.domain}"
  type    = "A"

  # health_check_id = "${aws_route53_health_check.forms.id}"

  alias {
    name = "${var.forms_dns_name}"
    zone_id = "${var.forms_zone_id}"
    evaluate_target_health = true
  }
}
