terraform {
  required_version = "~> 0.11.6"

  backend "consul" {
    address = "demo.consul.io"
    path    = "getting-started-dooCaifie3Ei"
    lock    = false
  }
}

provider "aws" {
  version = "~> 2.5"
  region     = "${var.region}"
}

# New resource for the S3 bucket our application will use.
resource "aws_s3_bucket" "example" {
  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.
  bucket = "terraform-gs-guide"
  acl    = "private"
}

# Change the aws_instance we declared earlier to now include "depends_on"
resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  #ami           = "${var.amis["us-east-1"]}"           # static lookup of a map
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }

  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
  depends_on = ["aws_s3_bucket.example"]
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}
