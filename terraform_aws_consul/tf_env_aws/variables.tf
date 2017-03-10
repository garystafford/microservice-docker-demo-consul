variable "aws_region" {
  description = "Default AWS Region for the VPC"
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

/*variable "consul_subnet_public_cidr" {
  description = "CIDR for the Consul Subnet 1"
  default = "10.0.0.0/24"
}*/

variable "consul_subnet_cidr1" {
  description = "CIDR for the Consul Subnet 1"
  default = "10.0.1.0/24"
}

variable "consul_subnet_cidr2" {
  description = "CIDR for the Consul Subnet 1"
  default = "10.0.2.0/24"
}

variable "consul_subnet_cidr3" {
  description = "CIDR for the Consul Subnet 1"
  default = "10.0.3.0/24"
}

variable "aws_amis_base" {
  description = "aws-us-east-1 Ubuntu 16.04 LTS w/ Docker 17.03.0-ce"
  default = {
    us-east-1 = "ami-b26ec9a4"
  }
}

/*variable "aws_amis_nat" {
  description = "Default AMIs by region for NAT instances"
  default = {
    us-east-1 = "ami-863b6391"
  }
}*/

variable "owner" {
  description = "Infrastructure Owner"
  default = "Gary Stafford"
}

variable "environment" {
  description = "Infrastructure Environment"
  default = "Consul AWS Demo"
}
