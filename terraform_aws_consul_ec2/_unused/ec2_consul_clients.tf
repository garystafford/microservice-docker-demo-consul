# Public security group for the Web UI
resource "aws_security_group" "consul" {
  name   = "security-group-consul"
  description = "Security group for Consul"

  vpc_id = "${aws_vpc.consul.id}"

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

# client1
resource "aws_instance" "consul-client-1" {
  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1a"
  count             = "1"

  key_name               = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.consul_1.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-client-1"
  }
}

# client2
resource "aws_instance" "consul-client-2" {
  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1b"
  count             = "1"

  key_name               = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.consul_2.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-client-2"
  }
}


# client3
resource "aws_instance" "consul-client-3" {
  connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1c"
  count             = "1"

  key_name               = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]
  subnet_id              = "${aws_subnet.consul_3.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-client-3"
  }
}
