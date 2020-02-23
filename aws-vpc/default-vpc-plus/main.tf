terraform {
  required_version = "~> 0.11.14"
}

provider "aws" {
  region  = "ap-southeast-2"
}

locals {
  common_tags = "${map(
    "Environment", "${terraform.workspace}",
    "Stack", "${var.stack_name}",
    "Creator", "terraform"
  )}"
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_internet_gateway" "default_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${data.aws_vpc.default.id}"]
  }
}

data "aws_subnet_ids" "default_public_subnets" {
  vpc_id = "${data.aws_vpc.default.id}"
}

################################################################################################################
# Create additional private subnets in default VPC, with NAT gateway allow egress to Internet using default IGW

resource "aws_subnet" "private_subnet_2a" {
  vpc_id            = "${data.aws_vpc.default.id}"
  cidr_block        = "172.31.48.0/20"
  availability_zone = "ap-southeast-2a"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-subnet-2a",
      "Tier", "private"
    )
  )}"
}

resource "aws_subnet" "private_subnet_2b" {
  vpc_id            = "${data.aws_vpc.default.id}"
  cidr_block        = "172.31.64.0/20"
  availability_zone = "ap-southeast-2b"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-subnet-2b",
      "Tier", "private"
    )
  )}"
}

resource "aws_subnet" "private_subnet_2c" {
  vpc_id            = "${data.aws_vpc.default.id}"
  cidr_block        = "172.31.80.0/20"
  availability_zone = "ap-southeast-2c"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-subnet-2c",
      "Tier", "private"
    )
  )}"
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "private_nat_gw" {
  allocation_id = "${aws_eip.nat_gw_eip.id}"
  subnet_id     = "${element(data.aws_subnet_ids.default_public_subnets.ids, 0)}"
  depends_on    = ["data.aws_internet_gateway.default_igw"]

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-nat-gw",
      "Tier", "private"
    )
  )}"
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${data.aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.private_nat_gw.id}"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "private-route-table",
      "Tier", "private"
    )
  )}"
}

resource "aws_route_table_association" "private_rt_subnet_2a" {
  route_table_id = "${aws_route_table.private_route_table.id}"
  subnet_id = "${aws_subnet.private_subnet_2a.id}"
}

resource "aws_route_table_association" "private_rt_subnet_2b" {
  route_table_id = "${aws_route_table.private_route_table.id}"
  subnet_id = "${aws_subnet.private_subnet_2b.id}"
}

resource "aws_route_table_association" "private_rt_subnet_2c" {
  route_table_id = "${aws_route_table.private_route_table.id}"
  subnet_id = "${aws_subnet.private_subnet_2c.id}"
}
