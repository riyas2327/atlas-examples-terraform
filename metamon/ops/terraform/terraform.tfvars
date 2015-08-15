/* You can either pass sensitive variables such as AWS keys on the
command line like below or set them as environment variables.

terraform remote config -backend-config name=$ATLAS_USERNAME/metamon
terraform get
terraform push -name $ATLAS_USERNAME/metamon \
    -var "atlas_username=$ATLAS_USERNAME" \
    -var "atlas_token=$ATLAS_TOKEN" \
    -var "aws_access_key=$AWS_ACCESS_KEY_ID" \
    -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"

See https://www.terraform.io/intro/getting-started/variables.html */

atlas_environment = "metamon"
region = "us-east-1"
availability_zone = "us-east-1a"
source_cidr_block = "172.31.0.0"

metamon_private_key = "ssh_keys/metamon-key.pem"
metamon_public_key = "ssh_keys/metamon-key.pub"
metamon_instance_type = "t2.micro"
metamon_count = "1"

consul_private_key = "ssh_keys/consul-key.pem"
consul_public_key = "ssh_keys/consul-key.pub"
consul_instance_type = "t2.micro"
consul_server_count = "3"
