# nomad-cluster

A Terraform project for deploying a Nomad cluster to Amazon Web Services.

> :warning: This project is for prototyping and does not contain
best practices for operating Nomad in production.

#### Atlas Configuration

To configure the project for [Atlas](https://atlas.hashicorp.com/), run:

```
terraform remote config -backend=Atlas -backend-config=name=$ATLAS_ORGANIZATION/$ATLAS_ENVIRONMENT
```

#### Environment Setup

Run the commands below and then click _Confirm & Apply_ on the new environment in [Atlas](https://atlas.hashicorp.com/) to build the environment.

```
$ terraform get -update aws-beginner-nomad-cluster/terraform/
...
$ terraform push -vcs=false -name=$ATLAS_ORGANIZATION/$ATLAS_ENVIRONMENT aws-beginner-nomad-cluster/terraform/
```

#### Environment Teardown
```
$ terraform destroy aws-beginner-nomad-cluster/terraform
```

#### Submitting Jobs

Job examples are available in [shared/jobs/](shared/nomad/jobs). See the
[Getting Started guide](https://www.nomadproject.io/intro/getting-started/jobs.html)
for how to submit and monitor jobs.
