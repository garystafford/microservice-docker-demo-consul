# server1
resource "aws_instance" "consul_server_1" {
  /*connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }*/

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1a"
  count             = "1"

  key_name               = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = "${aws_subnet.consul_1.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-server-1"
  }
}

# server2
resource "aws_instance" "consul_server_2" {
  /*connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }*/

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1b"
  count             = "1"

  key_name               = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = "${aws_subnet.consul_2.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-server-2"
  }
}


# server3
resource "aws_instance" "consul_server_3" {
  /*connection {
    user        = "ubuntu"
    private_key = "${file("~/.ssh/consul_aws_rsa")}"
    timeout     = "${connection_timeout}"
  }*/

  ami               = "${lookup(var.aws_amis_base, var.aws_region)}"
  instance_type     = "t2.nano"
  availability_zone = "us-east-1c"
  count             = "1"

  key_name               = "${aws_key_pair.consul_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = "${aws_subnet.consul_3.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-instance-consul-server-3"
  }
}
