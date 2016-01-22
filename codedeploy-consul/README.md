# codedeploy-consul

This example demonstrates using [Consul](https://www.consul.io/) for
service health checks and orchestrating deployments for an
[AWS CodeDeploy](https://aws.amazon.com/codedeploy/) application.

Specifically, Consul is used to:
- Register the CodeDeploy application in Consul's
[service catalog](https://www.consul.io/docs/agent/services.html) for service
discovery
- Mark the node as
["under maintenance"](https://www.consul.io/docs/commands/maint.html) during a
CodeDeploy deployment
- Prevent the CodeDeploy deployment from proceeding until the node and
application are healthy in Consul's service catalog

## Getting Started

[Terraform](https://terraform.io/) is used to provision the example environment on Amazon Web Services including the VPC and subnets, Consul cluster, and CodeDeploy instances. Additionally, a CodeDeploy Application named *SampleApp_Linux_Consul* and a CodeDeploy Deployment Group named *SampleApp_Linux_Consul* will be created.

[HashiCorp Atlas](https://hashicorp.com/atlas.html) is used to provide the initial bootstrap for the Consul cluster.

### Prerequisites

1. The following environments must be set in your local shell:
  ```
  # For Atlas
  $ export ATLAS_TOKEN=YOUR_ATLAS_TOKEN
  $ export ATLAS_USERNAME=YOUR_ATLAS_USERNAME

  # For AWS
  $ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
  $ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  $ export AWS_DEFAULT_REGION=us-west-2
  ```
2. You will need an S3 bucket for pushing application files to.

> This is not managed by Terraform because S3 buckets cannot be created, destroyed, and recreated quickly without [causing issues](http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html).

### Setup

To run this example:

1. Run the following command to generate an SSH key for use in this example.
  ```
  $ bash shared/ssh_keys/generate_key_pair.sh
  Generating RSA private key, 1024 bit long modulus
  .................................................................................++++++
  ........................++++++
  e is 65537 (0x10001)

  Public key: shared/ssh_keys/codedeploy-consul.pub
  Private key: shared/ssh_keys/codedeploy-consul.pem
  ```
1. Prepare the Terraform modules:
  ```
  $ terraform get -update terraform
  Get: file:///Users/clstokes/cc/hashicorp/atlas-examples/codedeploy-consul/shared (update)
  ```
1. Create the environment using Terraform:
  ```
  $ terraform apply terraform
  template_file.consul_update: Creating...
    rendered:                     "" => "<computed>"
  ...

  CodeDeploy Deployment Group Name: SampleApp_Linux_Consul

  To deploy a new version of the application:
    1) aws deploy push --application-name SampleApp_Linux_Consul --s3-location s3://YOUR_BUCKET/YOUR_PATH/SampleApp_Linux_Consul.zip --source applications/SampleApp_Linux_Consul/
    2) Follow the instructions in the output from the push command or use the AWS console.

  Happy deploying!
  ```
1. Follow the instructions in the output from the previous `terraform apply` step to push and deploy the sample application with CodeDeploy.

### Teardown

To teardown the example:

1. Use Terraform to destroy the environment:
  ```
  $ terraform destroy terraform
  Do you really want to destroy?
    Terraform will delete all your managed infrastructure.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value: yes

  template_file.consul_update: Refreshing state... (ID: 17b15c60a9d113b81903c777fcb7bcdfed5c80d5166bbd530c7a85ad265c9f96)
  ...
  aws_vpc.main: Destroying...
  aws_vpc.main: Destruction complete

  Apply complete! Resources: 0 added, 0 changed, 41 destroyed.
  ```
1. Clean up any remaining application files in your S3 bucket.
