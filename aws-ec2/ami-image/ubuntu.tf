data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    //values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
    //values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

output "ubuntu_ami_id" {
  value = "${data.aws_ami.ubuntu.id}"
}

output "ubuntu_ami_name" {
  value = "${data.aws_ami.ubuntu.name}"
}
