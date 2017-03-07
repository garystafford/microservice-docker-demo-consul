# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-internet-gateway"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a public subnet for consul-servers
resource "aws_subnet" "consul-servers" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.consul-servers_subnet_cidr}"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-subnet-consul-servers"
  }
}

resource "aws_route_table" "consul-servers" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
      Owner       = "${var.owner}"
      Terraform   = true
      Environment = "${var.environment}"
      Name        = "tf-route-table-consul-servers"
    }
}

resource "aws_route_table_association" "consul-servers" {
    subnet_id      = "${aws_subnet.consul-servers.id}"
    route_table_id = "${aws_route_table.consul-servers.id}"
}

# Create a public subnet for consul-workers
resource "aws_subnet" "consul-workers" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.consul-workers_subnet_cidr}"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-subnet-consul-workers"
  }
}

resource "aws_route_table" "consul-workers" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
      Owner       = "${var.owner}"
      Terraform   = true
      Environment = "${var.environment}"
      Name        = "tf-route-table-consul-workers"
    }
}

resource "aws_route_table_association" "consul-workers" {
    subnet_id      = "${aws_subnet.consul-workers.id}"
    route_table_id = "${aws_route_table.consul-workers.id}"
}
