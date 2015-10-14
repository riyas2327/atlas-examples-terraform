# General Setup

Below are different sections referenced throughout the Atlas Examples repo that explain how to get setup in order to accomplish certain tasks. Any variables that are in all caps that start with `YOUR_` should be replaced before running the command. Many projects will provide you with the actual commands that should be run.

## Create Atlas Account

Signup for an [Atlas account](https://atlas.hashicorp.com/account/new). The username you use to signup with will be your `ATLAS_USERNAME`. Save this username as an environment variable named `ATLAS_USERNAME`.

## Generate Atlas Token

After [creating an Atlas account](#create-atlas-account), [generate a token](https://atlas.hashicorp.com/settings/tokens). Save this token as an environment variable named `ATLAS_TOKEN`.

## Generate AWS Keys

[Generate AWS keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) to provision infrastructure in Amazon. Generate these keys and save your Access Key ID as an environment variable named `AWS_ACCESS_KEY_ID` and your Secret Access Key as an environment variable named `AWS_SECRET_ACCESS_KEY`.

## Generate Certs

From the base [`setup`]() directory, navigate to `scripts/.`

    $ cd scripts

Then run

    $ sh gen_cert.sh YOUR_DOMAIN.com YOUR_COMPANY YOUR_CERT_PATH

This will create a self-signed certificate that can be used across projects. A `.crt`, `.key`, and `.csr` will be placed in the location you specified in the third parameter, `YOUR_CERT_PATH`.

## Generate Keys

From the base [`setup`]() directory, navigate to `scripts/.`

    $ cd scripts

Then run

    $ sh gen_key.sh YOUR_KEY_PATH

If you have an existing private key you would like to use rather than generating a new one, pass the location of your existing private key as a second parameter into the shell script

    $ sh gen_key.sh YOUR_KEY_PATH ~/.ssh/my-existing-private-key.pem

This will create a .pem and .pub keypair in the location you specified in the first parameter, `YOUR_KEY_PATH`.

## Building Images with Packer

Image creation can be done locally or with Atlas, however, all examples run under the assumption you are using Atlas. You will need to have an [Atlas account](https://atlas.hashicorp.com/account/new) to provision using Atlas.

Be sure that your [`ATLAS_USERNAME`](#create-atlas-account), [`ATLAS_TOKEN`](#generate-atlas-token), and any other provider specific variables are set before runing Packer commands.

If this is the first time pushing Packer templates to Atlas, the builds **will fail**, this is okay. After pushing a template, go to the [Atlas Builds tab](https://atlas.hashicorp.com/builds). Navigate to each `Build Configuration`, click on `Variables` in the left navigation, and add the below environment variables based on the provider you're using. Then, queue each build again by going back to `Builds` in the left navigation and clicking `Queue Build`.

- Atlas Env Vars
  - `ATLAS_USERNAME`
- AWS Env Vars
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

** If you want to use a VPC/Subnet other than your providers default, be sure to fill in `vpc_id` and `subnet_id` for each of the Packer templates. If you're using AWS and deleted the default VPC, or one does not exist (Amazon EC2 "Classic" accounts), follow [these steps](../setup/vpc.md) to manually create one, or [create one with Terraform](terraform/aws/network/main.tf). **

Wait for the build(s) to finish and an `Artifact` to successfully be created before moving to the next step.

### Packer Templates

** Be sure to first read the [Building Images with Packer](#building-images-with-packer) section. **

Run the `packer push` command for each template specified in your project.

    $ packer push YOUR_PACKER_TEMPLATE_PATH.json

### Base Packer Templates

** Be sure to first read the [Building Images with Packer](#building-images-with-packer) section. **

The base artifacts created from these templates will be used as the source for child templates to avoid having to complete long running processes such as updating dependencies everytime you do a `packer push`.

Run the `packer push` command for each base template specified in your project.

    $ packer push YOUR_BASE_PACKER_TEMPLATE_PATH.json

### Child Packer Templates

** Be sure to first read the [Building Images with Packer](#building-images-with-packer) section. **

After your base templates have completed successfully and created `Artifacts`, run the `packer push` command for each child template specified in your project.

    $ packer push YOUR_CHILD_PACKER_TEMPLATE_PATH.json

These will fail initially, as mentioned in the [Building Images with Packer](#building-images-with-packer) section. After setting the variables for each build configuration, set the Base Artifact as well. You can accomplish this by going to `Settings` in the left navigation of each build configuration and selecting the appropriate Base Artifact under "Inject artifact ID during build".

## Upload Applications

First, go to the "Applications" tab in Atlas and click "New Application". If your application needs to be [compiled](#compile-applications), check the box "Compile Application", then click "Create". The project you're working in should specify the name of the application and if it's compiled.

Notice the following page gives instructions showing different ways you can upload your application to Atlas.

After creating the application, go to `Settings` in the left navigation, select the Build Template that this application will use, then click `Update application`. The project you're working in should specify which Build Template to use.

Upload the application using [GitHub](https://atlas.hashicorp.com/help/applications/uploading#github), [Vagrant Push](https://atlas.hashicorp.com/help/applications/uploading#vagrant-push), or the [Atlas Upload CLI](https://atlas.hashicorp.com/help/applications/uploading#upload-cli). Refer to the instructions given after creating the application for help with this ("App Version" in the left navigation of the application in Atlas).

Now that you have linked the Build Template, upload your application to kick off a new build.

### GitHub Integration

Go to "Integrations" in the left navigation of your "Application" in Atlas. Authenticate with GitHub if you have not already done so, then enter the integration information supplied by your project and click "Associate".

## Compile Applications

To compile "Applications" in Atlas, you need a `compile.json` file in the root directory of your application that tells Atlas how to compile it.

When [creating your Application](#upload-applications), you should have checked "Compile Application". You can update this by going to "Settings" in the left navigation of your application.

If you're using the GitHub Integration for your application upload, this will be the file that you will provide the path for when entering the "Application template".

## Atlas Upload CLI

To upload "Applications" to Atlas using the Atlas Upload CLI, get the [tool](https://github.com/hashicorp/atlas-upload-cli) first. You can use one of the included [sample apps](apps), or upload an existing one.

To upload your application to Atlas, run

    $ atlas-upload $ATLAS_USERNAME/YOUR_APP_NAME YOUR_APP_DIRECTORY

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
    $ terraform push -name $ATLAS_USERNAME/YOUR_ATLAS_ENVIRONMENT -var "atlas_token=$ATLAS_TOKEN" -var "atlas_username=$ATLAS_USERNAME"

The initial plan in Atlas after doing your first `terraform push` **will fail**, this is because you need to set some environment variables.

Go to the [Atlas Environments tab](https://atlas.hashicorp.com/environments) and click on your environment. Navigate to `Variables` and add the below to the `Environment Variables` section.

- AWS Env Vars
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION`

Once all environment variables have been added, go back to `Changes` on the left and queue another plan by clicking `Queue Plan`. Once the plan succeeds, click `Confirm & Apply` and it will provision all of your infrastructure! At the very end of the apply output, there will be instructions on how to manage everything.

To view what's going to happen locally before doing a `terraform push`, run

    $ terraform plan -var "atlas_token=$ATLAS_TOKEN" -var "atlas_username=$ATLAS_USERNAME"

If you want to destroy the environment, run

    $ terraform destroy -var "atlas_token=$ATLAS_TOKEN" -var "atlas_username=$ATLAS_USERNAME"

**Note:** `terraform destroy` deletes real resources, it is important that you take extra precaution when using this command. Verify that you are in the correct environment, verify that you are using the correct keys, and set any extra configuration necessary to prevent someone from accidentally destroying prod infrastructure.
