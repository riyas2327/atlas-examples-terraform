Rails App
=========
The files in this repository enable users to bring up a local Rails development
environment and then deploy the application to AWS. If you haven't deployed an
app with [Atlas](https://atlas.hashicorp.com) before, we recommend you start
with the [introductory
tutorial](https://atlas.hashicorp.com/help/getting-started/getting-started-overview).
Atlas by [HashiCorp](https://hashicorp.com) is a platform to develop, deploy,
and maintain applications on any infrastructure provider.

## Local development
To bring up a development environment, run `vagrant up` in the top directory
which contains the Vagrantfile. You can test changes and then view them locally
at localhost:8000. When you are satisfied with your changes, it's simple to
deploy them to production. 

To run your Rails app locally simply cd into the `/vagrant/project/app/`
directory and run `./bin/rails server -p 8000 -b 0.0.0.0`. By default when you
login to the vagrantbox you will be placed into the /vagrant directory.

## Deploy your application
The deployment process has three steps. The first step is sending the
application code to Atlas so it can be packaged as a deployable artifact. The
second step is configuring the deployable artifact by installing required
packages such as Apache, MySQL, etc. The final step is configuring the
infrastructure which the artifact is deployed onto. In this example, we'll
configure one t2.micro instances on AWS behind a load balancer. 

### Create an Atlas account
If you haven't already, you must create an [Atlas
account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=rails)
in order to securely deploy to AWS. Then generate an Atlas token in your
[account settings](https://atlas.hashicorp.com/settings/tokens) and set it as
an environment variable in order authorize communications with Atlas. 

`$ export ATLAS_TOKEN=YOUR_TOKEN`

### Push your application to Atlas
Send your application code to Atlas by running `vagrant push` in the top
directory which contains the Vagrantfile. Before pushing, be sure to update
the Vagrantfile with your username, otherwise you the push will fail.

### Configure the application to deploy to AWS
Now that Atlas has your application code, you must tell it how to package the
code and create an AMI. This is done with a *build configuration*, which is the
file `rails-ami.json` in the ops/prod folder. Update the build configuration
sections `push` and `post-processors` with your Atlas username. The `push`
section creates the build configuration in Atlas, and the `post-processors`
section tells the build to output an AMI. Run `packer push -create rails-ami`
in the directory with `rails-ami.json` to create the build configuration in
Atlas. 

Also note the `variables` section, which holds aws keys. To securely store them
in Atlas, click on your rails-ami build configuration in the [Operations
tab](https://atlas.hashicorp.com/operations), then "Variables" in the left
navigation.

Enter your aws_secret_key and aws_access_key, which you can find in your [AWS
console](http://aws.amazon.com/console/). Now run `packer push rails-ami` and
the variables will be accessible by the build configuration. 

Finally, you must link your application pushed in step one to the build
configuration just created. To do this, click on your rails-ami build
configuration in the [Operations tab](https://atlas.hashicorp.com/operations),
then "Linked Applications" in the left navigation. Enter your username and
application name, then set the Path equal to "/app". This tells the build
configuration to package your application and place it in the /app directory.

Now that your build configuration and application are linked (woohoo!) anytime
you push a new application version it will begin a new build of the AMI with
the updated application code.

### Deploy to AWS
Now that you have an AMI configured with Rails, you need to deploy it on an AWS
instance. This is done with the terraform configuration `rails.tf` in the
ops/prod folder. To deploy to AWS, you must update `rails.tf` with your Atlas
username and your AWS keys. Once the template is configured run `terraform
apply`, this will create and deploy the Rails artifact on a t2.micro instance
behind a load balancer. If you run `terraform show` and navigate to the
dns_name in your browser, you'll see you have a nicely deployed Rails app! 

## Develop and deploy workflow
Now anytime you want to test changes in development, just run `vagrant up`.
When you're happy with your changes, run `vagrant push` to send the changes to
Atlas. This will kick off a build to create an AMI with your updated
application. When the build finishes, just run`terraform apply` to deploy the
artifact to AWS. 

For advanced users, you can read more about the tools
[Vagrant](https://vagrantup.com), [Packer](https://packer.io), and
[Terraform](https://terraform.io).

## Considerations...
By default this configuration deploys the database and the application
together. In future revisions this will be changed however keep in mind that
any stored data in a database will be wiped clean if you re-deploy your
application.
