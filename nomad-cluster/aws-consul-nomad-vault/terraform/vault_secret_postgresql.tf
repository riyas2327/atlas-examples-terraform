resource "null_resource" "vault_postgres_consul_template_files" {
  count = "${var.server_nodes}"

  connection {
    user        = "ubuntu"
    private_key = "${file(module.shared.private_key_path)}"
    host        = "${element(aws_instance.server_vault.*.public_ip,count.index)}"
  }

  provisioner "file" {
    source      = "${module.shared.path}/vault/consul-template-demo"
    destination = "/home/ubuntu/"
  }
}

data "template_file" "vault_postgres_instructions" {
  template = <<EOF

    # You must initialize and unseal each Vault server first!!!

    vault mount postgresql
    vault write postgresql/config/lease lease=5s lease_max=5s
    vault write postgresql/config/connection \
      connection_url="postgresql://${rds_username_password}:${rds_username_password}@${rds_address}:5432/${rds_db_name}"

    vault policy-write readonly ./policy.hcl
    vault auth-enable userpass
    vault write auth/userpass/users/cameron \
      password=stokes \
      policies=readonly
    vault auth -method=userpass username=cameron

    consul-template -config config.hcl 2> /dev/null
  EOF

  vars {
    rds_username_password = "${var.rds_username_password}"
    rds_address           = "${aws_db_instance.main.address}"
    rds_db_name           = "${var.rds_db_name}"
  }
}

output "vault_postgres_instructions" {
  value = "${data.template_file.vault_postgres_instructions.rendered}"
}
