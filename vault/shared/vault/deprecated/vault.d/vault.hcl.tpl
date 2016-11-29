cluster_name = "{{ atlas_environment }}"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

backend "consul" {
  path           = "vault"
  address        = "127.0.0.1:8500"
}
