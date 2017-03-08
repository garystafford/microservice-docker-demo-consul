# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "consul" {
  vpc_id = "${aws_vpc.consul.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-internet-gateway"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.consul.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.consul.id}"
}

resource "aws_subnet" "consul_1" {
  vpc_id                  = "${aws_vpc.consul.id}"
  cidr_block              = "${var.consul_subnet_cidr1}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-subnet-consul-1"
  }
}

resource "aws_route_table" "consul_1" {
    vpc_id = "${aws_vpc.consul.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.consul.id}"
    }

    tags {
      Owner       = "${var.owner}"
      Terraform   = true
      Environment = "${var.environment}"
      Name        = "tf-route-table-consul-1"
    }
}

resource "aws_route_table_association" "consul_1" {
    subnet_id      = "${aws_subnet.consul_1.id}"
    route_table_id = "${aws_route_table.consul_1.id}"
}

resource "aws_subnet" "consul_2" {
  vpc_id                  = "${aws_vpc.consul.id}"
  cidr_block              = "${var.consul_subnet_cidr2}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-subnet-consul-2"
  }
}

resource "aws_route_table" "consul_2" {
    vpc_id = "${aws_vpc.consul.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.consul.id}"
    }

    tags {
      Owner       = "${var.owner}"
      Terraform   = true
      Environment = "${var.environment}"
      Name        = "tf-route-table-consul-2"
    }
}

resource "aws_route_table_association" "consul_2" {
    subnet_id      = "${aws_subnet.consul_2.id}"
    route_table_id = "${aws_route_table.consul_2.id}"
}

resource "aws_subnet" "consul_3" {
  vpc_id                  = "${aws_vpc.consul.id}"
  cidr_block              = "${var.consul_subnet_cidr3}"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-subnet-consul-3"
  }
}

resource "aws_route_table" "consul_3" {
    vpc_id = "${aws_vpc.consul.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.consul.id}"
    }

    tags {
      Owner       = "${var.owner}"
      Terraform   = true
      Environment = "${var.environment}"
      Name        = "tf-route-table-consul-3"
    }
}

resource "aws_route_table_association" "consul_3" {
    subnet_id      = "${aws_subnet.consul_3.id}"
    route_table_id = "${aws_route_table.consul_3.id}"
}
