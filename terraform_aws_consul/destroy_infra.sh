#!/bin/sh

# Destroy AWS Infrastructure

set -e

echo "Destroying AWS infrastructure..."

cd ${JENKINS_HOME}/terraform_aws_consul/tf_env_aws/

terraform remote config \
  -backend=s3 \
  -backend-config="bucket=tf-remote-state-gstafford" \
  -backend-config="key=terraform_consul.tfstate" \
  -backend-config="region=us-east-1"

terraform destroy -force

echo "Destroying AWS infrastructure complete..."
