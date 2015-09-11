# Deploy Infrastructure in AWS

This project will deploy an end to end infrastructure including the below resources.

- Networking
  - VPC
  - 3 Public subnets
  - 3 Private subnets
  - 3 Ephemeral subnets
  - NAT
  - OpenVPN
  - Bastion host
- Data
  - RDS (defaults to Postgres)
  - ElastiCache (defaults to Redis)
  - Consul cluster
  - Vault HA with Consul backend
  - RabbitMQ server using blue/green deploy strategy
- Compute
  - Windows IIS web server with ASP.NET web app using blue/green deploy strategy

This is just a basic setup, everything is configurable.

## Create Base Artifacts with Packer

Read the [Packer base template docs]() before you begin.

Navigate to the base `ops` directory, this is where you will perform your `packer push` commands for the base templates specified in your project.

    $ packer push packer/aws/ubuntu/base.json
    $ packer push packer/aws/windows/base.json

## Create Child Artifacts with Packer

After your base artifacts have been created, push the rest of your Packer templates that depend on them.

Read the [Packer child template]() docs before you begin.

    $ packer push packer/aws/ubuntu/consul.json
    $ packer push packer/aws/ubuntu/vault.json
    $ packer push packer/aws/ubuntu/rabbitmq.json

Read the [Application docs]() to push your Application and finish the child Packer builds.

    $ packer push packer/aws/windows/web.json
    $ atlas-upload YOUR_ATLAS_USERNAME/asp.net-app apps/ASP.NET

## Provision Infrastructure with Terraform

Read the [Terraform docs]() before you begin.

From the base `ops` directory, navigate to `terraform/projects/01/.`

    $ cd terraform/projects/01

If this is the first time you have run Terraform in this project, you will need to setup the remote config and download the modules

    $ terraform remote config -backend-config name=$ATLAS_USERNAME/example-01
    $ terraform get

If everything looks good, run

    $ terraform push -name $ATLAS_USERNAME/example-01 -var "atlas_token=$ATLAS_TOKEN"
