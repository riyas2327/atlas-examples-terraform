# ECS Blue/Green Deploys

This is a simple example of how to leverage modules to do blue/green task definition deploys on ECS. Below is an example of how to do a blue/green deploy. You could pass in the `definition` by updating `terraform.tfvars`, the `` variable default, or passing in at the command line with a `-var` switch statement.

### Setup

Ensure you have your AWS credentials set in your environment (`AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY`).

```
terraform get
```

Optionally run `terraform plan` before any `terraform apply` to see what Terraform is going to do.

### Blue Deploy

Ensure `blue_definitions` JSON input has the correct `image` version specified to provision your first 5 task definitions. In our example, this is `v1`.

```
terraform apply -var blue_version=v1 -var blue_count=5 -var=green_version=v2 -var green_count=0
```

### Green Deploy

Now assume there is a new image created, `v2`, that you want to deploy. Without changing the `blue` module variables, I update the `green_definitions` variable to point to image `v2` and the `green_count` variable to be the count I want.

```
terraform apply -var blue_version=v1 -var blue_count=5 -var=green_version=v2 -var green_count=5
```

### Scale down Blue

```
terraform apply -var blue_version=v1 -var blue_count=0 -var=green_version=v2 -var green_count=5
```

### Deploy new version (Blue)

```
terraform apply -var blue_version=v3 -var blue_count=5 -var=green_version=v2 -var green_count=5
```

### Scale down Green

```
terraform apply -var blue_version=v3 -var blue_count=5 -var=green_version=v2 -var green_count=0
```
