# Primary Terraform reference:
# https://github.com/hashicorp/terraform/tree/master/examples/aws-two-tier

# credentials set via environment variables
provider "aws" {}

resource "aws_key_pair" "auth" {
  key_name   = "${var.aws_key_name}"
  public_key = "${file(var.public_key_path)}"
}

/*https://www.terraform.io/docs/state/remote/s3.html*/
/*source ~/Documents/Notes/garystafford_cred.env
terraform remote config \
  -backend=s3 \
  -backend-config="bucket=tf-remote-state-gstafford" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=us-east-1"*/

data "terraform_remote_state" "consul_aws" {
    backend = "s3"
    config {
        bucket = "tf-remote-state-gstafford"
        key    = "terraform.tfstate"
        region = "us-east-1"
    }
}
