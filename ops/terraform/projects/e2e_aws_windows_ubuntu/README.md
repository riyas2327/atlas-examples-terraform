# Deploy End to End Windows/Ubuntu Infrastructure

## Create Artifacts with Packer

Verify you've completed all of the [Packer getting started steps]() before you begin the [Packer section]().

Navigate to the base `ops` directory, this is where you will perform your `packer push` commands for the base templates specified in your project.

    $ packer push packer/ubuntu_base.json
    $ packer push packer/windows_base.json

Base templates usually take a long time to complete. After your base templates have completed successfully, push the rest of your Packer templates that depend on them.

    $ packer push packer/consul.json
    $ packer push packer/vault.json
    $ packer push packer/rabbitmq.json
    $ packer push packer/app.json

## Provision Infrastructure with Terraform

From the base `ops` directory, navigate to `terraform/projects/e2e_aws_windows_ubuntu/.`

    $ cd terraform/projects/e2e_aws_windows_ubuntu

If this is the first time you have run Terraform in this project, you will need to setup the remote config and download the modules

    $ terraform remote config -backend-config name=$ATLAS_USERNAME/e2e-aws-windows-ubuntu
    $ terraform get

If everything looks good, run

    $ terraform push -name $ATLAS_USERNAME/e2e-aws-windows-ubuntu -var "atlas_token=$ATLAS_TOKEN"
