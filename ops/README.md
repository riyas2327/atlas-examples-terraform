# Ops

This repository contains the various ops things we need to run HashiCorp
services:

  - Packer templates
  - Terraform modules

## Building Images with Packer

AMI creation is done with Atlas. You will need to have an Atlas account with permissions on the organization. Do not forget to set your `ATLAS_TOKEN` environment variable!

Begin the image building process in Atlas by pushing up the appropriate packer template.

    $ packer push packer/ami.json

If this is a brand new project in Atlas, the first build  **will fail**, but that is okay. On the Atlas website, add any variables, then re-run.

## Deploying with Terraform

First of all, ignore the changes on the local cache of the terraform statefile:

    git update-index --assume-unchanged terraform/.terraform/terraform.tfstate

Terraform root module is in the terraform directory:

    $ cd terraform/

If this is the first time you have run Terraform, you wil need to download the modules. The modules that comprise our infrastructure are in `terraform/modules/` and can be downloaded by running:

    $ terraform get

To iterate, run:

    $ terraform plan

and submit a Pull Request to have a teammate review the changes.

If this is the first time running Terraform in the this repo, you will need to create IAM credentials for your user in the AWS console and save them to the proper environment variables. You can also specify the values directly on the command line as variables:

    $ terraform plan

The following environment variables are configurable:

- `AWS_ACCESS_KEY` - _(required)_ the AWS access key to use
- `AWS_SECRET_KEY` - _(required)_ the AWS secret key to use
- `AWS_REGION` - _(optional)_ the AWS region, default: `us-east-1`

After you have gotten the thumbs up from someone, merge your Pull Request, update your local repo, and notify the #ops Slack channel that you are deploying so you do not accidentially cross with someone else.

If no one says to stop, run:

    $ terraform apply

And wait for it to complete. If there are any errors, let Slack know. The `apply` command will update the terraform state files. **Commit the state files back into the repo** after the command runs sucessfully and push to the remote.
