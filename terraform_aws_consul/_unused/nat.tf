# NAT instance security group
# http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_NAT_Instance.html#NATSG
resource "aws_eip" "consul_nat" {
  instance = "${aws_nat_gateway.consul_nat_gtwy.id}"
  vpc = true
}

resource "aws_security_group" "consul_nat" {
  name        = "consul_nat"
  description = "AWS security group for NAT Server"

  # Inbound from Internet for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "${var.consul_subnet_cidr1}",
      "${var.consul_subnet_cidr2}",
      "${var.consul_subnet_cidr3}"
    ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "${var.consul_subnet_cidr1}",
      "${var.consul_subnet_cidr2}",
      "${var.consul_subnet_cidr3}"
    ]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.consul.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-security-group-consul-nat"
  }
}

resource "aws_nat_gateway" "consul_nat_gtwy" {
  depends_on    = ["aws_internet_gateway.consul"]
  allocation_id = "${aws_eip.consul_nat.id}"
  subnet_id     = "${aws_subnet.consul_public.id}"
}

# NAT instance
/*resource "aws_instance" "consul_nat" {
  ami                         = "${lookup(var.aws_amis_nat, var.aws_region)}"
  instance_type               = "t2.nano"
  availability_zone           = "us-east-1d"
  key_name                    = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids      = ["${aws_security_group.consul_nat.id}"]
  subnet_id                   = "${aws_subnet.consul_public.id}"
  source_dest_check           = false
  associate_public_ip_address = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-public-nat"
  }
}*/
