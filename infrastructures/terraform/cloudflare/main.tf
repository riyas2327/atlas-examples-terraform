/*
Get the name_servers output from the main run, cd into this dir and

TF_VAR_name_servers=ip1,ip2,ip3
terraform apply
*/

variable "domain" {}
variable "name_servers" {}

resource "cloudflare_record" "ns" {
  count = "${length(split(",", var.name_servers))}"

  domain = "hashicorptest.com"
  name = "${element(split(".", var.domain), 0)}"
  type = "NS"
  ttl = "120"
  value = "${element(split(",", var.name_servers), count.index)}"
}

output "hostnames" { value = "${cloudflare_record.*.hostname}" }
