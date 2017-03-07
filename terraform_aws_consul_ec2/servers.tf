# Public security group for the Web UI
resource "aws_security_group" "consul" {
  name   = "security-group-consul"
  description = "Security group for Consul"

  vpc_id = "${aws_vpc.default.id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-security-group-consul"
  }
}

# manager1
resource "aws_instance" "consul-server1" {
  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1a"
  count             = "1"

  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.consul-servers.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-server1"
  }
}

# worker1
resource "aws_instance" "consul-worker1" {
  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1b"
  count             = "1"

  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.consul-workers.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-worker1"
  }
}
