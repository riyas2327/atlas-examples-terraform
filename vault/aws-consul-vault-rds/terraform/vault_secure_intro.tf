data "template_file" "vault_secure_intro_instructions" {
  template = <<EOF

    vault auth-enable aws-ec2
    vault write auth/aws-ec2/role/readonly bound_ami_id=$${base_image} policies=readonly max_ttl=500h
  EOF

  vars {
    base_image = "${module.shared.base_image}"
  }
}

output "vault_secure_intro_instructions" {
  value = "${data.template_file.vault_secure_intro_instructions.rendered}"
}
