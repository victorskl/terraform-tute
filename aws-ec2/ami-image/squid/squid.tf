provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "squid" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu16-squid-1.0.2-*"]
  }

  // cdistest - https://github.com/uc-cdis/cloud-automation/tree/master/packer
  owners = ["707767160287"]
}

output "squid_ami_id" {
  value = "${data.aws_ami.squid.id}"
}

output "squid_ami_name" {
  value = "${data.aws_ami.squid.name}"
}

// terraform init
// terraform apply
// terraform output
