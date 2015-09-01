# Project Overview

The goal of this project is to deploy a Spark cluster on AWS using Packer, Terraform, Consul, and Atlas.

# Atlas Deployment Steps

## Prerequisites

1. Set environment variables on your local machine:
    ```
    # for Atlas
    export ATLAS_USERNAME=YOUR_USERNAME                # Change this value.
    export ATLAS_TOKEN=YOUR_TOKEN                      # Change this value.

    export ATLAS_ENVIRONMENT=spark

    # for Packer
    export AWS_DEFAULT_REGION=us-east-1
    export SOURCE_AMI=ami-9a562df2

    # for Terraform
    export TF_VAR_region=$AWS_DEFAULT_REGION
    export TF_VAR_source_ami=$SOURCE_AMI

    # for AWS
    export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY           # Change this value.
    export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY       # Change this value.
    ```

## Builds

1. In the `packer/` directory, run `packer push -name="$ATLAS_USERNAME/consul" consul.json`.
1. Set the following variables to your build in Atlas:
    ```
    AWS_DEFAULT_REGION
    SOURCE_AMI
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    ```

1. Click *Rebuild* on your failed build.
1. Repeat for `spark-master.json` and `spark-slave.json` also in the `packer/` directory.

## Environments

1. In the `terraform` directory, run `terraform remote config -backend="Atlas" -backend-config="name=$ATLAS_USERNAME/$ATLAS_ENVIRONMENT"`.
1. In the `terraform` directory, run `terraform push -var="access_key=$AWS_ACCESS_KEY_ID" -var="secret_key=$AWS_SECRET_ACCESS_KEY" -var="region=$AWS_DEFAULT_REGION" -var="source_ami=$SOURCE_AMI" -var="atlas_user_token=$ATLAS_TOKEN" -var="atlas_username=$ATLAS_USERNAME" -var="atlas_environment=$ATLAS_ENVIRONMENT" -name="$ATLAS_USERNAME/$ATLAS_ENVIRONMENT"`.

For future Terraform changes after the initial `push`, you can run just `terraform push -name="$ATLAS_USERNAME/$ATLAS_ENVIRONMENT" -input=false`.

## Spark Example Application

1. Once the cluster is *ALIVE*, run `MASTER=spark://MASTER_HOSTNAME:7077 /opt/spark/default/bin/run-example SparkPi 10` from any of the Spark instances to run an example Spark application.
