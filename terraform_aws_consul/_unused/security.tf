resource "aws_security_group" "consul_internet_access" {
  name   = "consul_internet_access"
  description = "Security group for Consul - Internet access"

  vpc_id = "${aws_vpc.consul.id}"

  # CLI RPC
  ingress {
    from_port   = 8400
    to_port     = 8400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # UI / HTTP API
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS Interface
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS Interface
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound from Internet for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to Internet to install Docker Images?
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
    Name        = "tf-sec-grp-consul-inet-access"
  }
}

# https://www.consul.io/docs/agent/options.html
# https://www.consul.io/docs/internals/architecture.html
resource "aws_security_group" "consul" {
  name   = "consul_cluster_communications"
  description = "Security group for Consul cluster communications"

  vpc_id = "${aws_vpc.consul.id}"

  # Replication
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # LAN Gossip / Serf LAN
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # LAN Gossip / Serf LAN
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # WAN Gossip / Serf WAN
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # WAN Gossip / Serf WAN
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "udp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # Outbound to Internet to install Docker Images?
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
