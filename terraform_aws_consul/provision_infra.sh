#!/bin/sh

# Provision infrastructure

set -e

echo "Building AWS infrastructure..."

cd tf_env_aws/

terraform remote config \
  -backend=s3 \
  -backend-config="bucket=tf-remote-state-gstafford" \
  -backend-config="key=terraform_consul.tfstate" \
  -backend-config="region=us-east-1"

terraform plan
terraform apply

echo "Building AWS infrastructure complete..."
