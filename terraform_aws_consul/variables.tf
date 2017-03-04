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

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default = "10.0.0.0/24"
}

variable "owner" {
  description = "Infrastructure Owner"
  default = "Gary Stafford"
}

variable "environment" {
  description = "Infrastructure Environment"
  default = "Consul AWS Demo"
}
