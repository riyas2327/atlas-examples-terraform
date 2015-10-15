# Project Overview

The goal of this project is to deploy a Spark cluster on AWS using Packer, Terraform, Consul, and Atlas.

# Atlas Deployment Steps

Run the commands below from the `spark` directory.

### Packer

```
packer push packer/spark-consul.json
```

```
packer push packer/spark-master.json
```

```
packer push packer/spark-slave.json
```

### Terraform

Once the Packer builds have completed, you can proceed with the Terraform commands.

#### Configure for Atlas

```
terraform remote config -backend="Atlas" -backend-config="name=$ATLAS_USERNAME/spark-cluster"
```

#### Get Terraform Modules

```
terraform get -update terraform/
```

#### Push To Atlas

```
terraform push -vcs=false -name="$ATLAS_USERNAME/spark-cluster" terraform/
```

#### Apply with Terraform Locally

```
terraform apply terraform/
```

#### Destroy with Terraform Locally

```
terraform destroy terraform/
```
