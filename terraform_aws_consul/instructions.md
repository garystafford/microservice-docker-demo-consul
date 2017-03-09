# Docker for AWS

```bash
source consul_aws_cred.env

terraform remote config \
  -backend=s3 \
  -backend-config="bucket=tf-remote-state-gstafford" \
  -backend-config="key=terraform_consul.tfstate" \
  -backend-config="region=us-east-1"

terraform validate
terraform plan
terraform apply
terraform show

sudo apt-get update
sudo apt-get -y upgrade
```

```bash
# http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html
# https://cloud-images.ubuntu.com/locator/ec2/
# https://docs.docker.com/engine/installation/linux/ubuntu/
# https://docs.docker.com/engine/installation/linux/linux-postinstall/
# Start with Ubuntu 16.04 LTS AMI - ami-09b3691f

ssh -i ~/.ssh/consul_aws_rsa ubuntu@<ec2-ami>

sudo apt-get remove docker docker-engine
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y docker-ce
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
exit # required to use without sudo
```

```text
ubuntu@ip-10-0-0-199:~$ docker -v
Docker version 17.03.0-ce, build 3a232c8
```

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
- [AWS CLI Queries](https://alestic.com/2013/11/aws-cli-query/)
