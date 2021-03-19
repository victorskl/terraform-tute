data "aws_ami" "centos" {
  most_recent = true

  // using CentOS 7 product code from https://wiki.centos.org/Cloud/AWS
  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # CentOS.org
}

output "centos_ami_id" {
  value = "${data.aws_ami.centos.id}"
}

output "centos_ami_name" {
  value = "${data.aws_ami.centos.name}"
}
