# vault

A set of example Terraform projects deploying a Consul and Vault cluster.

> :warning: This project is for prototyping and does not contain
best practices for operating in production.

> :information_source: All commands shown below should be run from the
`vault` directory.

## Requirements

The following environment variables are required:

```
# For AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

#### Environment Creation

```
$ terraform get -update aws-consul-vault/terraform/
...
$ terraform apply aws-consul-vault/terraform/
```

#### Environment Teardown
```
$ terraform destroy aws-consul-vault/terraform/
```
