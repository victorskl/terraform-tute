// Using region's default VPC through [Data Sources](https://www.terraform.io/docs/configuration-0-11/data-sources.html)

provider "aws" {
  region = "ap-southeast-2"
}

data "aws_vpc" "default" {
  default = true
}

# Fetch AZs in the current region
data "aws_availability_zones" "default" {}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

data "aws_subnet" "default_0" {
  vpc_id = "${data.aws_vpc.default.id}"
  id = "${element(data.aws_subnet_ids.default.ids, 0)}" // pick one at index 0
}

//---

output "default_security_group" {
  value = ["${data.aws_security_group.default.id}, ${data.aws_security_group.default.arn}, ${data.aws_security_group.default.name}, ${data.aws_security_group.default.description}"]
}

output "default_subnet_0" {
  value = ["${data.aws_subnet.default_0.id}, ${data.aws_subnet.default_0.arn}, ${data.aws_subnet.default_0.cidr_block}, ${data.aws_subnet.default_0.availability_zone}"]
}

output "default_azs" {
  value = ["${data.aws_availability_zones.default.names}"]
}

output "default_subnets" {
  value = ["${data.aws_subnet_ids.default.ids}"]
}

output "default_vpc" {
  value = ["${data.aws_vpc.default.id}, ${data.aws_vpc.default.arn}, ${data.aws_vpc.default.cidr_block}"]
}

//---
// terraform apply
// terraform output
// terraform show
