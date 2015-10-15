# Atlas Examples

This repository contains application and infrastructure examples
for [Atlas](https://atlas.hashicorp.com/) by HashiCorp.

## Setup

Set the environment variables listed below.

### Environment Variables

```
# For Atlas
ATLAS_TOKEN
ATLAS_USERNAME

# For AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

### Atlas Variables

To generate an Atlas Token, visit your account page in [Atlas](https://atlas.hashicorp.com/settings/tokens?utm_source=github&utm_medium=examples&utm_campaign=readme).

Your _Atlas Username_ is either your personal username in Atlas or
the name of the organization you belong to within Atlas.

### AWS Access Keys

To generate AWS access keys, visit the [IAM Management Console](https://console.aws.amazon.com/iam/home?region=us-east-1#home).

## Writing Examples

Pretty simple - create a folder named after the example. Add a README if
setup is required, and add supporting files.

> Please try to follow the above environment variables as inputs to keep
projects consistent and easy to adopt.

## Issues

To report issues (such as typographical errors or confusion) in these examples,
please open a GitHub issue. **For Atlas-specific support, please email
[support@hashicorp.com](mailto:support@hashicorp.com).**


## Documentation

Additional documentation on Atlas, Vagrant, Packer, Terraform, and Consul
can be [read here](https://atlas.hashicorp.com/help#documentation).
