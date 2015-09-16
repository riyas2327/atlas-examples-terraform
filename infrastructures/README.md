# Projects

Below are the infrastructures we currently have examples for. Go to each project to see what will be provisioned.

- [Complete AWS Infrastructure](terraform/projects/01/README.md)

## Getting Started

This repository contains example [projects](#projects) showing how to deploy infrastructures across many different operating sytems and cloud providers. Check out the list of [projects](#projects) we currently have examples for. The example [projects](#projects) will range from small, simple, infrastructures, to very complex, end to end infrastructures.

There are many different Packer & Terraform templates that each project utilizes. You can think of this as a library of Packer templates and Terraform modules that allow you to provision unique infrastructures by referencing the different templates and modules. We've tried to set this repository up in a way that we don't have to duplicate code, allowing templates and modules to be used across many projects.

Each project is a best practices guide for how to use HashiCorp tooling to provision that specific type of infrastructure. Use each as a reference when building your own infrastructure. The best way to get started is to pick a project that resembles an infrastructure you are looking to build, get it up and running, then configure and modify it to meet your specific needs.

No one example will be exactly what you need, but it should provide you with enough examples to get you headed in the right direction. This is all open source, so please contribute as you see fit.

A couple things to keep in mind...

- Each projects README will reference different sections in here to get your environment properly setup to build the infrastructure at hand.
- Any variables that are in all caps that start with `YOUR_` should be replaced before running the command.
- Each section will assume you are starting in the base [`infrastructures`]() directory.
- Each project will assume you're using Atlas. If you plan on doing everything locally, there are portions of projects that may not work due to the extra features Atlas provides that we are take advantage of.
- Each projects instructional documentation is running off of the assumption that certain information will be saved as environment variables. If you do not wish to use environment variables, there are different ways to pass this information, but you may have to take extra undocumented steps to get commands to work properly.

## Create Atlas Account

Signup for an [Atlas account](https://atlas.hashicorp.com/account/new). The username you use to signup with will be your `ATLAS_USERNAME`. Save this username as an environment variable named `ATLAS_USERNAME`.

## Generate Atlas Token

After [creating an Atlas account](#create-atlas-account), [generate a token](https://atlas.hashicorp.com/settings/tokens). Save this token as an environment variable named `ATLAS_TOKEN`.

## Generate AWS Keys

[Generate AWS keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) to provision infrastructure in Amazon. Generate these keys and save your Access Key ID as an environment variable named `AWS_ACCESS_KEY_ID` and your Secret Access Key as an environment variable named `AWS_SECRET_ACCESS_KEY`.

## Generate Certs

From the base [`infrastructures`]() directory, navigate to `scripts/.`

    $ cd scripts

Then run

    $ sh gen_cert.sh YOUR_DOMAIN.com YOUR_COMPANY YOUR_CERT_NAME

This will create a self-signed certificate that can be used across projects. A `.crt`, `.key`, and `.csr` will be placed in [`terraform/certs`](terraform/certs).

## Generate Keys

From the base [`infrastructures`]() directory, navigate to `scripts/.`

    $ cd scripts

Then run

    $ sh gen_key.sh YOUR_KEY_NAME

If you have an existing private key you would like to use rather than generating a new one, pass the location of your existing private key as a second parameter into the shell script

    $ sh gen_key.sh YOUR_KEY_NAME ~/.ssh/my-existing-private-key.pem

This will create a .pem and .pub keypair in [`terraform/keys/.`](terraform/keys) to be used across projects.

## Building Images with Packer

Image creation can be done locally or with Atlas, however, all examples run under the assumption you are using Atlas. You will need to have an [Atlas account](https://atlas.hashicorp.com/account/new) to provision use Atlas.

Be sure that your [`ATLAS_USERNAME`](#create-atlas-account), [`ATLAS_TOKEN`](#generate-atlas-token), and any other provider specific variables are set before runing Packer commands.

If this is the first time pushing Packer templates to Atlas, the builds **will fail**, this is okay. After pushing a template, go to the [Atlas Builds tab](https://atlas.hashicorp.com/builds). Navigate to each `Build Configuration`, click on `Variables` in the left navigation, and add the below environment variables based on the provider you're using. Then, queue each build again by going back to `Builds` in the left navigation and clicking `Queue Build`.

- Atlas Env Vars
  - `ATLAS_USERNAME`
- AWS Env Vars
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

** If you want to use a VPC/Subnet other than your providers default, be sure to fill in `vpc_id` and `subnet_id` for each of the Packer templates. If you're using AWS and deleted the default VPC, or one does not exist (Amazon EC2 "Classic" accounts), follow [these steps](https://github.com/hashicorp/atlas-examples/blob/master/aws-setup/vpc.md) to manually create one, or [create one with Terraform](terraform/aws/network/main.tf). **

Wait for the build(s) to finish and an `Artifact` to successfully be created before moving to the next step.

### Packer Templates

** Be sure to first read the [Building Images with Packer](#building-images-with-packer) section. **

Navigate to the base [`infrastructures`]() directory, this is where you will perform your `packer push` commands. Run the `packer push` command for each template specified in your project.

    $ packer push YOUR_PACKER_TEMPLATE_PATH.json

### Base Packer Templates

** Be sure to first read the [Building Images with Packer](#building-images-with-packer) section. **

The base artifacts created from these templates will be used as the source for child templates to avoid having to complete long running processes such as updating dependencies everytime you do a `packer push`.

Navigate to the base [`infrastructures`]() directory, this is where you will perform your `packer push` commands for the base templates specified in your project. Run the `packer push` command for each base template specified in your project.

    $ packer push YOUR_BASE_PACKER_TEMPLATE_PATH.json

### Child Packer Templates

** Be sure to first read the [Building Images with Packer](#building-images-with-packer) section. **

After your base templates have completed successfully and created `Artifacts`, navigate to the base [`infrastructures`]() directory, this is where you will perform your `packer push` commands. Run the `packer push` command for each child template specified in your project.

    $ packer push YOUR_CHILD_PACKER_TEMPLATE_PATH.json

These will fail initially, as mentioned in the [Building Images with Packer](#building-images-with-packer) section. After setting the variables for each build configuration, set the base artifacts as well. You can accomplish this by going to `Settings` in the left navigation of each build configuration and selecting the appropriate Artifact under "Inject artifact ID during build".

## Upload Applications

To upload "Applications" to Atlas, get the [atlas-upload-cli tool](https://github.com/hashicorp/atlas-upload-cli). You can use one of the included [sample apps](apps), which are simple "Hello, World!" web apps, or upload an existing one.

From the [`infrastructures`]() base directory, run

    $ atlas-upload $ATLAS_USERNAME/YOUR_APP_NAME YOUR_APP_DIRECTORY

After uploading the application, go to the Build Configurations in Atlas that will be linked to this app.

Go to `Links` in the left navigation of the Build Configuration and enter the following into each field

- `YOUR_ATLAS_USERNAME` for "Application Username"
- `YOUR_APP_NAME` for "Application Name"
- `YOUR_APP_DIRECTORY` for "Path"

The project you're working in should specify what these values should be.

Once you have linked the app in the Build Configuration, queue the build again by going back to `Builds` in the left navigation and clicking `Queue Build`.

## Deploy with Terraform

**Before provisioning, make sure you understand that Terraform will create real resources for the specified provider that cost money. If you're deploying a large infrastructure, remember to destroy it when you're done or it could get expensive.**

Update all of the `YOUR_` variables in your projects `terraform.tfvars` file and check that everything is configured to your liking.

The Terraform root module that you should be running all Terraform commands from is the directory of your project that contains the `terraform.tfvars` file.

The following variables are configurable and can be passed in via the command line with the `-var` switch, however, you should be fine running the Terraform commands defined in your project.

- AWS Env Vars
  - `AWS_ACCESS_KEY_ID` - _(required)_ the AWS access key to use
  - `AWS_SECRET_ACCESS_KEY` - _(required)_ the AWS secret key to use
  - `AWS_DEFAULT_REGION` - _(optional)_ the AWS region to use, defaults to `us-east-1`

See the [Terraform variables section](https://www.terraform.io/intro/getting-started/variables.html) for more information on how to pass variables.

Run the Terraform commands specified in your project

    $ terraform remote config -backend-config name=$ATLAS_USERNAME/YOUR_ATLAS_ENVIRONMENT
    $ terraform get
    $ terraform push -name $ATLAS_USERNAME/YOUR_ATLAS_ENVIRONMENT -var "atlas_token=$ATLAS_TOKEN"

The initial plan in Atlas after doing your first `terraform push` **will fail**, this is because you need to set some environment variables.

Go to the [Atlas Environments tab](https://atlas.hashicorp.com/environments) and click on your environment. Navigate to `Variables` and add the below to the `Environment Variables` section.

- AWS Env Vars
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION`

Once all environment variables have been added, go back to `Changes` on the left and queue another plan by clicking `Queue Plan`. Once the plan succeeds, click `Confirm & Apply` and it will provision all of your infrastructure! At the very end of the apply output, there will be instructions on how to manage everything.

To view what's going to happen locally before doing a `terraform push`, run

    $ terraform plan -var "atlas_token=$ATLAS_TOKEN"

If you want to destroy the environment, run

    $ terraform destroy -var "atlas_token=$ATLAS_TOKEN"

**Note:** `terraform destroy` deletes real resources, it is important that you take extra precaution when using this command. Verify that you are in the correct environment, verify that you are using the correct keys, and set any extra configuration necessary to prevent someone from accidentally destroying prod infrastructure.
