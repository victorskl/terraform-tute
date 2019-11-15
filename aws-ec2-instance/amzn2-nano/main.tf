provider "aws" {
  region = "ap-southeast-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "http" "myip" {
  url = "https://domains.google.com/checkip"
}

resource "aws_security_group" "poke_sg" {
  name = "my-poke-sg"
  description = "Poke around instance security group created by myapp"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "poke-around-instance"
  }
}

resource "aws_key_pair" "my_ssh_keypair" {
  key_name   = "${var.your_ssh_key_pair_name}"
  public_key = "${var.your_ssh_public_key}"
}

resource "aws_instance" "poke_around" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"

  key_name = "${aws_key_pair.my_ssh_keypair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.poke_sg.id}"]
  subnet_id = "${data.aws_subnet_ids.all.id}"

  tags = {
    Name = "poke-around-instance"
  }
}
