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
  - RabbitMQ server
- Compute
  - Windows IIS web server with ASP.NET web app using blue/green deploy strategy

## General Setup

Be sure to follow all instructions closely. Many of these steps require pre/post work to be completed or it won't work.

- [Create an Atlas Account](../../../README.md#create-atlas-account) and save your username as an environment variable
- [Generate an Atlas Token](../../../README.md#generate-atlas-token) and save your token as an environment variable
- [Generate AWS Keys](../../../README.md#generate-aws-keys) and save the access key and secret as an environment variables
- [Generate Certs](../../../README.md#generate-certs)
  - `sh gen_cert.sh awsexample.com example example`
- [Generate Keys](../../../README.md#generate-keys)
  - `sh gen_key.sh example` or `sh gen_key.sh example ~/.ssh/my-existing-private-key.pem` if you have an existing private key you want to use

## Create Base Artifacts with Packer

First read the [Building Images with Packer](../../../README.md#building-images-with-packer) docs.

Then, follow the [Packer base template docs](../../../README.md#base-packer-templates) to run the below commands.

Be sure to replace `YOUR_CERT_NAME` for the `cert_name` variable in [base.json](../../../packer/aws/ubuntu/base.json#L13) with the certificate name you used when [generating a cert](../../../README.md#generate-certs). This was the third parameter passed into `sh gen_cert.sh`.

    $ packer push packer/aws/ubuntu/base.json
    $ packer push packer/aws/windows/base.json

If you decide to update any of the artifact names, be sure those name changes are reflected in [terraform.tfvars](terraform.tfvars#L36-L47).

## Create Child Artifacts with Packer

After your base artifacts have been created, push the rest of your Packer templates that depend on them.

Follow the [Packer child template docs](../../../README.md#child-packer-templates) to run the below commands.

Be sure to replace `YOUR_CERT_NAME` for the `cert_name` variable in [vault.json](../../../packer/aws/ubuntu/vault.json#L13) with the certificate name you used when [generating a cert](../../../README.md#generate-certs). This was the third parameter passed into `sh gen_cert.sh`.

    $ packer push packer/aws/ubuntu/consul.json
    $ packer push packer/aws/ubuntu/vault.json
    $ packer push packer/aws/ubuntu/rabbitmq.json

Then, follow the [Upload Application docs](../../../README.md#upload-applications) to run the below commands.

    $ packer push packer/aws/windows/web.json
    $ atlas-upload YOUR_ATLAS_USERNAME/asp.net-app apps/asp.net

If you decide to update any of the artifact names, be sure those name changes are reflected in [terraform.tfvars](terraform.tfvars#L36-L47).

## Provision Infrastructure with Terraform

Follow the [Deploy with Terraform docs](../../../README.md#deploy-with-terraform) to run the below commands.

From the base `infrastructures` directory, navigate to `terraform/projects/01/.`

    $ cd terraform/projects/01

If this is the first time you have run Terraform in this project, you will need to setup the remote config and download the modules.

If you updated the `atlas_environment` variable in [`terraform.tfvars`](terraform.tfvars#L17) from `example-01`, be sure that change is reflected in the below `terraform remote config` and `terraform push` commands.

    $ terraform remote config -backend-config name=$ATLAS_USERNAME/example-01
    $ terraform get

If everything looks good, run

    $ terraform push -name $ATLAS_USERNAME/example-01 -var "atlas_token=$ATLAS_TOKEN"

This takes about 20 minutes to run as RDS takes quite awhile to provision. Don't forget to `terraform destroy` you're environment when your done so you don't rack up AWS bills (unless you plan on keeping it around).

That's it!
