provider "aws" {}

resource "aws_key_pair" "consul_auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.public_key_path)}"
}

data "terraform_remote_state" "consul_aws" {
    backend = "s3"
    config {
        bucket = "tf-remote-state-gstafford"
        key    = "terraform_consul.tfstate"
        region = "us-east-1"
    }
}
