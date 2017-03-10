resource "aws_subnet" "consul_public" {
  vpc_id                  = "${aws_vpc.consul.id}"
  cidr_block              = "${var.consul_subnet_public_cidr}"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = true

  tags {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "tf-subnet-consul-public"
  }
}

resource "aws_route_table" "consul_public" {
    vpc_id = "${aws_vpc.consul.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.consul.id}"
    }

    tags {
      Owner       = "${var.owner}"
      Terraform   = true
      Environment = "${var.environment}"
      Name        = "tf-route-table-consul-public"
    }
}

resource "aws_route_table_association" "consul_public" {
    subnet_id      = "${aws_subnet.consul_public.id}"
    route_table_id = "${aws_route_table.consul_public.id}"
}
