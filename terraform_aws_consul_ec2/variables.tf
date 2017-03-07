variable "aws_region" {
  description = "EC2 Region for the VPC"
  default = "us-east-1"
}

variable "public_key_path" {
  default = "~/.ssh/consul_aws_rsa.pub"
}

variable "aws_key_name" {
  default = "consul_aws"
}

variable "connection_timeout" {
  default = "120s"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
}

variable "consul-servers_subnet_cidr" {
  description = "CIDR for the Consul Servers Subnet"
  default = "10.0.1.0/24"
}

variable "consul-workers_subnet_cidr" {
  description = "CIDR for the Consul Workers Public Subnet"
  default = "10.0.2.0/24"
}

variable "aws_amis_base" {
  description = "aws-us-east-1 Ubuntu 16.04 LTS w/ Docker 17.03.0-ce"
  default = {
    us-east-1 = "ami-b4ec48a2"
  }
}

variable "owner" {
  description = "Infrastructure Owner"
  default = "Gary Stafford"
}

variable "environment" {
  description = "Infrastructure Environment"
  default = "Consul AWS Demo"
}
