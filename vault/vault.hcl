backend "consul" {
  address = "consul.service.consul:8500"
  path = "vault"
}

listener "tcp" {
  address = "172.16.0.2:8200"
  tls_disable = "true"
}
