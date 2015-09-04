variable "name" {}
variable "iam_admins" {}

# IAM
module "iam" {
  source = "./iam"

  name   = "${var.name}"
  admins = "${var.iam_admins}"
}

# Keys
module "keypair_main" {
  source = "./keypair"

  name = "${var.name}"
}

# Certs
module "cert_main" {
  source = "./cert"

  name = "${var.name}"
}

output "admin_users" { value = "${module.iam.admin_users}" }
output "admin_access_key_ids" { value = "${module.iam.admin_access_key_ids}" }
output "admin_secret_access_keys" { value = "${module.iam.admin_secret_access_keys}" }
output "admin_statuses" { value = "${module.iam.admin_statuses}" }

output "main_key_name" { value = "${module.keypair_main.key_name}" }
output "main_key_path" { value = "${module.keypair_main.key_path}" }

output "main_cert_name"          { value = "${module.cert_main.name}" }
output "main_cert_crt_path"      { value = "${module.cert_main.crt_path}" }
output "main_cert_key_path"      { value = "${module.cert_main.key_path}" }
