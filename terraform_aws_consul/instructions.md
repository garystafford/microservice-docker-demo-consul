# Docker for AWS

**Edge with VPC Template**

```bash
aws cloudformation create-stack \
  --stack-name consul-demo \
  --template-url "https://editions-us-east-1.s3.amazonaws.com/aws/edge/Docker-no-vpc.tmpl" \
  --parameters \
    \
    ParameterKey=ManagerSize,ParameterValue=1 \
    ParameterKey=ClusterSize,ParameterValue=2 \
    \
    ParameterKey=KeyName,ParameterValue=consul_aws \
    ParameterKey=EnableSystemPrune,ParameterValue=yes \
    ParameterKey=EnableCloudWatchLogs,ParameterValue=yes \
    \
    ParameterKey=ManagerInstanceType,ParameterValue=t2.micro \
    ParameterKey=ManagerDiskSize,ParameterValue=20 \
    ParameterKey=ManagerDiskType,ParameterValue=standard \
    \
    ParameterKey=InstanceType,ParameterValue=t2.micro \
    ParameterKey=WorkerDiskSize,ParameterValue=20 \
    ParameterKey=WorkerDiskType,ParameterValue=standard \
    \
    ParameterKey=Vpc,ParameterValue=vpc-897b3aef \
    ParameterKey=PubSubnetAz1,ParameterValue=subnet-b734d1ff \
    ParameterKey=PubSubnetAz2,ParameterValue=subnet-13c8e848 \
    ParameterKey=PubSubnetAz3,ParameterValue=subnet-c359c7a6 \
  --capabilities CAPABILITY_IAM
```

**Stable Template**

```bash
aws cloudformation create-stack \
  --stack-name consul-demo \
  --template-url "https://editions-us-east-1.s3.amazonaws.com/aws/stable/Docker.tmpl" \
  --parameters \
    \
    ParameterKey=ManagerSize,ParameterValue=1 \
    ParameterKey=ClusterSize,ParameterValue=2 \
    \
    ParameterKey=KeyName,ParameterValue=consul_aws \
    ParameterKey=EnableSystemPrune,ParameterValue=yes \
    ParameterKey=EnableCloudWatchLogs,ParameterValue=no \
    \
    ParameterKey=ManagerInstanceType,ParameterValue=t2.micro \
    ParameterKey=ManagerDiskSize,ParameterValue=20 \
    ParameterKey=ManagerDiskType,ParameterValue=standard \
    \
    ParameterKey=InstanceType,ParameterValue=t2.micro \
    ParameterKey=WorkerDiskSize,ParameterValue=20 \
    ParameterKey=WorkerDiskType,ParameterValue=standard \
    \
  --capabilities CAPABILITY_IAM
```

```text
{
   "StackId": "arn:aws:cloudformation:us-east-1:931066906971:stack/consul-demo/5b683ec0-011c-11e7-a68b-50d5ca6e6082"
}
```

```bash
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE
aws cloudformation delete-stack --stack-name consul-demo
aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].PublicIpAddress'
aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-server-1' --output text --query 'Reservations[*].Instances[*].PublicIpAddress'
tf-instance-test-docker-ce
aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-server-1' --output text --query 'Reservations[*].Instances[*].PrivateIpAddress'
```

## References

- [AWS for Docker](https://www.docker.com/docker-aws)
- [AWS for Docker Template](https://editions-us-east-1.s3.amazonaws.com/aws/edge/Docker-no-vpc.tmpl)
- [Ubuntu AMIs](https://cloud-images.ubuntu.com/locator/ec2/)
- [AWS CLI Queries](https://alestic.com/2013/11/aws-cli-query/) <http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html> <https://cloud-images.ubuntu.com/locator/ec2/> <https://docs.docker.com/engine/installation/linux/ubuntu/> <https://docs.docker.com/engine/installation/linux/linux-postinstall/>
