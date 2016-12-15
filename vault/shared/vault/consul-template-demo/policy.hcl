path "postgresql/creds/readonly" {
  policy = "read"
}

path "sys/renew/*" {
  policy = "write"
}
