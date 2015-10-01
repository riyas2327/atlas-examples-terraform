# Hyperspace and Google
This is a demo / walkthrough of using Atlas and HashiCorp tools with
[Google Cloud Platform](https://cloud.google.com/).

The sample app deployed is a 1980's style, real-time, multiplayer space
shooter called [Hyperspace](https://github.com/kenpratt/hyperspace). This
app was chosen because it has a front-end Javascript component and a
backend server written in Go and can be configured to use several features
from Google Compute Engine (GCE).

Clone this repo locally and then proceed to set up your Google Cloud Platform
account and HashiCorp tools.

# Google Cloud Platform Account and Auth
First, you will need to make sure you have a active
[Google Cloud Platform](https://cloud.google.com/) account. You can sign up
for a free-trial account, but will still need to set up billing and have a
credit card on file.

1. Once you log into the Developers Console, make sure you have enabled
   billing and reviewed / accepted the terms of service.
2. Next, make sure to create a new GCP Project and record the Project ID.
3. Navigate to the Compute - Compute Engine page and ensure GCE is ready.
4. Finaly, navigte to APIs & auth - Credentials and under Service Accounts
   download the JSON account file. You will need to name this file `pkey.json`
   and save the file in both the `packer/` directory and `terraform/`
   directories.

# Atlas
Visit the Atlas web site, create an account, and generate a new token. In your
local environment, set a few environment variables:

```sh
export GOOGLE_PROJECT_ID=graphite-demos
export ATLAS_USERNAME=erjohnso
export ATLAS_TOKEN=<create a new token on atlas and paste it here>

export TF_VAR_GOOGLE_PROJECT_ID=${GOOGLE_PROJECT_ID}
export TF_VAR_ATLAS_USERNAME=${ATLAS_USERNAME}
export TF_VAR_ATLAS_TOKEN=${ATLAS_TOKEN}
```

# Packer
Download and install Packer to build your GCE images configured with the
Hyperspace game.

## Packer Hyperspace Frontend
Create the Atlas artifact Google image for the hyperspace Javascript front-end.
This requires you to run,

```sh
packer push -name $ATLAS_USERNAME/hyperspace-fe hyperspace-fe.json
```

This will push the config up to Atlas, create a new build, and promptly fail
to build the image.  To fix this, navigate to your build in the Atlas web
console and go to the Variables page. Make sure to set GOOGLE_PROJECT_ID and
ATLAS_USERNAME. Now, you can fire off the build again by repeating your
last shell command,

```sh
packer push -name $ATLAS_USERNAME/hyperspace-fe hyperspace-fe.json
```

You can watch the progress of the Atlas/Packer build on the Atlas web UI.

NOTE: You may need to edit the `hyperspace-fe.json` file to set the path to your
      Google Cloud Platform JSON account file.

## Packer Hyperspace Backend
Create the Atlas artifact Google image for the hyperspace back-end. This
requires you to run,

```sh
packer push -name $ATLAS_USERNAME/hyperspace-be hyperspace-be.json
```

This will push the config up to Atlas, create a new build, and promptly fail
to build the image.  To fix this, navigate to your build in the Atlas web
console and go to the Variables page. Make sure to set GOOGLE_PROJECT_ID and
ATLAS_USERNAME. Now, you can fire off the build again by repeating your
last shell command,

```sh
packer push -name $ATLAS_USERNAME/hyperspace-be hyperspace-be.json
```

You can watch the progress of the Atlas/Packer build on the Atlas web UI.

NOTE: You may need to edit the `hyperspace-be.json` file to set the path to your
      Google Cloud Platform JSON account file.

# Terraform
Now, you should have two Atlas artifacts created and Google images for your
game, you can switch over to the terraform directory and create your
infrastructure and start playing the game with a few friends.

```sh
terraform apply
```

This should do the following:

* Create a GCE instance named `hyperspace-be`
* Create 2 GCE instances prefixed with `hyperspace-fe-` (0 and 1)
* Create a GCE load-balancer in front of both front-end instances
* Create a firewall rule to allow TCP port 80 (web) traffic to your front-ends

Once terraform finishes execution, you should see an output variable for
the external public IP address of the GCE load-balancer.  You can point
your web browser to this IP to begin playing Hyperspace.

NOTE: You may need to edit the `main.tf` file to set the path to your
      Google Cloud Platform JSON account file.

# Tearing it down
Once you're done with the demo, to save costs, you may want to turn down
all of your GCE resources. You can do that with,

```sh
terraform destroy
```

NOTE: The images you built are stored as `atlas_artifacts` and won't be
      destroyed. Because of the dependency chain, the GCE instances will
      not be deleted, so you will need to do that by hand.

# Troubleshooting
1. Auth errors: Make sure you have your Google Cloud Platform JSON account
   file saved as `pkey.json` locally to both the `packer/` and `terraform/`
   directories. Alternatively, you will need to edit the packer/terraform
   files to reference your JSON account file another way.

# TODO
1. Add support for consul to better match the HAProxy/Nodejs example

