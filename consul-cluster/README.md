# consul-cluster

A set of example projects of varying complexity for deploying a Consul cluster with Terraform.

## Setup

To deploy each of the examples in this project, you will need an SSH key and
a set of variables specific to your environment.

### SSH Key

The `shared/ssh_keys/generate_key_pair.sh` script can assist with creating or
copying an existing key for your environment. In both manners (creating a new
key or copying an existing one), the script will place a private key file
and a public key file in `shared/ssh_keys`. This is necessary for Terraform
to be able to create and then provision your Consul cluster.

#### Create New Key

To create a new key, run the command below where the first argument is your
key name. This will generate a new private key and public key in the
`shared/ssh_keys` directory.

```
$ bash shared/ssh_keys/generate_key_pair.sh atlas-example
No key pair exists and no private key arg was passed, generating new keys.
Generating RSA private key, 1024 bit long modulus
................++++++
..........++++++
e is 65537 (0x10001)

Public key: shared/ssh_keys/atlas-example.pub
Private key: shared/ssh_keys/atlas-example.pem
$
```

#### Copy Existing Key

To copy an existing key, run the command below where the first argument
is your key name and the second argument is the path to the existing
_private_ key file. This will copy your private key to the
`shared/ssh_keys` directory and generate a new public key in the same
directory.

```
$ bash shared/ssh_keys/generate_key_pair.sh atlas-example ~/.ssh/atlas-examples
Using private key [/Users/clstokes/.ssh/atlas-examples] for key pair.

Public key: shared/ssh_keys/atlas-example.pub
Private key: shared/ssh_keys/atlas-example.pem
$
```

## aws-intermediate-consul-cluster

Run the commands below from the `consul-cluster` directory.

### Packer

```
packer push shared/packer/consul_client.json
```

```
packer push shared/packer/consul_server.json
```

### Terraform

#### Configure for Atlas

```
terraform remote config -backend="Atlas" -backend-config="name=$ATLAS_USERNAME/consul-cluster"
```

#### Get Terraform Modules

```
terraform get -update aws-intermediate-consul-cluster/terraform/
```

#### Push To Atlas

```
terraform push -vcs=false -name="$ATLAS_USERNAME/consul-cluster" aws-intermediate-consul-cluster/terraform/
```

#### Apply with Terraform Locally

```
terraform apply aws-intermediate-consul-cluster/terraform/
```

#### Destroy with Terraform Locally

```
terraform destroy aws-intermediate-consul-cluster/terraform/
```

> Note: The `environment-variables.sh` script does not need to be sourced
each time, but is there for ease of copying and pasting.
