// simple-vpc set up from:
// https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple-vpc

provider "aws" {
  region = "ap-southeast-2"
  version = "~> 2.6"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.60.0"

  name = "simple-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
