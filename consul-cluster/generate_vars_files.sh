#!/bin/bash

FILE_ENV_VARS=environment-variables.sh
FILE_ENV_VARS_TMP=$FILE_ENV_VARS.tmp

TEXT_PROMPT='Please enter your'

function write_env_vars_file () {
  cat > $FILE_ENV_VARS_TMP << EOF
#!/bin/bash

export AWS_ACCESS_KEY_ID="$INPUT_AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$INPUT_AWS_SECRET_KEY"
export AWS_REGION="$INPUT_REGION_EAST"
export AWS_REGION_WEST="$INPUT_REGION_WEST"
export SOURCE_AMI="$INPUT_SOURCE_AMI"
export KEY_NAME="$INPUT_KEY_NAME"
export ATLAS_TOKEN="$INPUT_ATLAS_TOKEN"
export ATLAS_ORGANIZATION="$INPUT_ATLAS_ORGANIZATION"
export ATLAS_ENVIRONMENT="$INPUT_ATLAS_ENVIRONMENT"

export TF_VAR_access_key="$INPUT_AWS_ACCESS_KEY"
export TF_VAR_secret_key="$INPUT_AWS_SECRET_KEY"
export TF_VAR_region="$INPUT_REGION_EAST"
export TF_VAR_region_west="$INPUT_REGION_WEST"
export TF_VAR_source_ami="$INPUT_SOURCE_AMI"
export TF_VAR_key_name="$INPUT_KEY_NAME"
export TF_VAR_atlas_token="$INPUT_ATLAS_TOKEN"
export TF_VAR_atlas_organization="$INPUT_ATLAS_ORGANIZATION"
export TF_VAR_atlas_environment="$INPUT_ATLAS_ENVIRONMENT"

EOF
}

EXISTING_FILES=""
if [ -f "$FILE_ENV_VARS" ]; then
  EXISTING_FILES="$FILE_ENV_VARS"
fi

if [ ! -z "$EXISTING_FILES" ]; then
  echo "The file(s) [$EXISTING_FILES] already exists. Continuing will overwrite this file."
  echo "Only 'yes' will be accepted to confirm."
  read -e -p "Enter a value: " INPUT_CONTINUE
  if [ "$INPUT_CONTINUE" != "yes" ]; then
    echo "Exiting..."
    exit 1
  fi
fi

[ -f "$FILE_ENV_VARS_TMP" ] && rm $FILE_ENV_VARS_TMP
echo ""

#
# Gather all variables
#
read -e -p "$TEXT_PROMPT AWS Access Key: " INPUT_AWS_ACCESS_KEY
read -e -p "$TEXT_PROMPT AWS Secret Key: " INPUT_AWS_SECRET_KEY
read -e -p "$TEXT_PROMPT AWS Region (East): " INPUT_REGION_EAST
read -e -p "$TEXT_PROMPT AWS Region (West): " INPUT_REGION_WEST
read -e -p "$TEXT_PROMPT Ubuntu Source AMI: " INPUT_SOURCE_AMI
read -e -p "$TEXT_PROMPT SSH Key Name: " INPUT_KEY_NAME
read -e -p "$TEXT_PROMPT Atlas Token: " INPUT_ATLAS_TOKEN
read -e -p "$TEXT_PROMPT Atlas Organization or User: " INPUT_ATLAS_ORGANIZATION
read -e -p "$TEXT_PROMPT Atlas Environment: " INPUT_ATLAS_ENVIRONMENT

write_env_vars_file

#
# Finish file
#
mv $FILE_ENV_VARS_TMP $FILE_ENV_VARS
echo ""
echo "Environment variables file:    $FILE_ENV_VARS"
