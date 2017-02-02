# ECS Blue/Green Deploys

This is a simple example of how to leverage modules to do blue/green task definition deploys on ECS. All you need to do is pass a few variables to your Terraform commands to accomplish this.

### Setup

Ensure you have your AWS credentials set in your environment (`AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY`).

```
terraform get
```

Optionally run `terraform plan` before any `terraform apply` to see what Terraform is going to do.

Variables can either be passed as a command line `-var` switch (below approach) or defined in `terraform.tfvars`. If you'd like, you can also just hardcode the values into `foo.tf`.

### V1 (Blue) Deploy

Deploy your initial version of the application under the Blue group. Notice `blue_version` is set to `v1` and `blue_count` is set to `5` which will create 5 ECS task definitions at image version `v1`. `green_count` is set to `0` so it won't create any.

```
terraform apply -var blue_version=v1 -var blue_count=5 -var=green_version=v2 -var green_count=0
```

### V2 (Green) Deploy

Now let's say there is a new version of the application image (`v2`) you want to deploy safely. Without changing the `blue` variables, update the `green_version` to `v2` and `green_count` to `5`.

```
terraform apply -var blue_version=v1 -var blue_count=5 -var=green_version=v2 -var green_count=5
```

### Scale Down V1 (Blue)

Once `v2` has been successfully deployed and is reporting as healthy, it's now safe to scale down `v1`. To do so, leave the `green` variables, but change `blue_count` to `0`.

```
terraform apply -var blue_version=v1 -var blue_count=0 -var=green_version=v2 -var green_count=5
```

### V3 (Blue) Deploy

Now let's say there is a `v3` of the application that you want to deploy. We want to keep `v2` (Green) still running until `v3` is successfully deployed and reporting as healthy. To do so, change `blue_version` to `v3` and `blue_count` to `5`.

```
terraform apply -var blue_version=v3 -var blue_count=5 -var=green_version=v2 -var green_count=5
```

### Scale Down V2 (Green)

Once again, now that `v3` has been successfully deployed and is reporting as healthy, we can safely scale down `v2` by changing the `green_count` to `0`.

```
terraform apply -var blue_version=v3 -var blue_count=5 -var=green_version=v2 -var green_count=0
```

### Conclusion

By leveraging modules and command line variables in Terraform, we can safely and easily deploy ECS task definitions containing new versions of application images. All you need to do is keep switching back and forth between Blue and Green.

It is also common to do canary style deploys where you start by introducing one new task definition, then slowly scale up to the appropriate amount. So instead of going from `0` to `5`, you start with `1` and ensure it deployed successfully and works as expected, then `2`, then `4`, then `5`.

You can also choose to scale up one group as you scale down the other at the same time. This prevents you from having a bunch of extra task definitions hanging around, especially during times in which you'd like the new version to soak for awhile.

If you want to get really creative you can interpolate the task definition `count` using Divide (`/`) so you can scale as a % rather than a specific number.

```
  variable "blue_pct"    { }
  variable "green_pct"   { }
  variable "final_count" { default = "5" }

  blue_count  = "${ceil((var.blue_pct / 100.0) * var.final_count)}"
  green_count = "${ceil((var.green_pct / 100.0) * var.final_count)}"

  terraform apply -var blue_version=v1 -var blue_pct=100 -var=green_version=v2 -var green_pct=0
  terraform apply -var blue_version=v1 -var blue_pct=100 -var=green_version=v2 -var green_pct=50
  terraform apply -var blue_version=v1 -var blue_pct=50 -var=green_version=v2 -var green_pct=50
  terraform apply -var blue_version=v1 -var blue_pct=50 -var=green_version=v2 -var green_pct=100
  terraform apply -var blue_version=v1 -var blue_pct=0 -var=green_version=v2 -var green_pct=100
```

To use this workflow, just uncomment all places variables `final_count`, `blue_pct`, and `green_pct` are used and comment out all places variables `blue_count` and `green_count` are used.
