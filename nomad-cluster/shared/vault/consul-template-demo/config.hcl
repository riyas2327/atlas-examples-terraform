template {
  source      = "template.ctmpl"
  destination = "output.txt"
  command     = "cat output.txt"
}

vault {
  address     = "http://active.vault.service.consul:8200"
  renew_token = false
}
