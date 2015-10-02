# nomad-cluster

A Terraform project for deploying a Nomad cluster to Amazon Web Services.

> :warning: This project is for prototyping and does not contain
best practices for operating Nomad in production.

#### Environment Setup

```
$ terraform get -update aws-beginner-nomad-cluster/terraform/
...
$ terraform apply aws-beginner-nomad-cluster/terraform
```

#### Environment Teardown
```
$ terraform destroy aws-beginner-nomad-cluster/terraform
```

#### Submitting Jobs

Job examples are available in [shared/jobs/](shared/jobs/). Please see the
[Getting Started guide](https://www.nomadproject.io/intro/getting-started/jobs.html)
for how to submit and monitor jobs.
