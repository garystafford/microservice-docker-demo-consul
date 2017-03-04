```bash
source consul_aws_cred.env

terraform validate
terraform plan
terraform apply
terraform show

https://www.docker.com/docker-aws
https://editions-us-east-1.s3.amazonaws.com/aws/edge/Docker-no-vpc.tmpl


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
  ParameterKey=PubSubnetAz1,ParameterValue=subnet-99a739fc \
  ParameterKey=PubSubnetAz2,ParameterValue='' \
  ParameterKey=PubSubnetAz3,ParameterValue='' \
--capabilities CAPABILITY_IAM

```

```text
{
   "StackId": "arn:aws:cloudformation:us-east-1:931066906971:stack/consul-demo/5b683ec0-011c-11e7-a68b-50d5ca6e6082"
}
```
