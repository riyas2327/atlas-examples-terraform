cluster_name = "{{ datacenter }}"

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

backend "consul" {
  path           = "vault"
  address        = "127.0.0.1:8500"
  advertise_addr = "https://{{ node_name }}.node.consul:8200"
}
