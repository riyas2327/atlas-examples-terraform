# nomad-cluster

A set of example Terraform projects deploying a Nomad cluster to Amazon Web
Services and Google Compute Engine.

> :warning: This project is for prototyping and does not contain
best practices for operating Nomad in production.

> :information_source: All commands shown below should be run from the
`nomad-cluster` directory.

## Requirements

The following environment variables are required:

```
# For Atlas
TF_VAR_atlas_token
TF_VAR_atlas_username

# For AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION

# For Google
GOOGLE_CREDENTIALS
GOOGLE_PROJECT
```

#### Atlas Configuration

To configure the project for [Atlas](https://atlas.hashicorp.com/), run:

```
terraform remote config -backend=Atlas -backend-config=name=$ATLAS_USERNAME/nomad-cluster
```

#### Environment Setup

Run the commands below and then click _Confirm & Apply_ on the new environment in [Atlas](https://atlas.hashicorp.com/) to build the environment.

```
$ terraform get -update aws-beginner-nomad-cluster/terraform/
...
$ terraform push -vcs=false -name=$ATLAS_USERNAME/nomad-cluster aws-beginner-nomad-cluster/terraform/
```

#### Environment Teardown
```
$ terraform destroy aws-beginner-nomad-cluster/terraform
```

#### Submitting Jobs

Job examples are available in [shared/jobs/](shared/nomad/jobs). See the
[Getting Started guide](https://www.nomadproject.io/intro/getting-started/jobs.html)
for how to submit and monitor jobs.
