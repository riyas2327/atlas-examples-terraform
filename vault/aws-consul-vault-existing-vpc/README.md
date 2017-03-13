# aws-consul-vault-existing-vpc

Creates an environment with:
- Three Consul servers, one in each private subnet, joined by ec2 tags
- Three Vault servers, one in each private subnet

## Requirements

The following environment variables must be set:

```
AWS_DEFAULT_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```
