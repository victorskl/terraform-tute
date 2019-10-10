terraform {
  required_version = "~> 0.11.6"

  backend "s3" {}
}

locals {
  space = "${terraform.workspace}"

  envs = {
    default = "dev"
    prod = "prod"
    stag = "stag"
  }

  env = "${lookup(local.envs, local.space)}"
}

provider "aws" {
  version = "~> 2.5"
  region = "${var.region}"
}

module "common" {
  source = "../../modules/common"
  //source = "git::https://github.com/victorskl/terraform-tute.git//gs-workspace/modules/common"
  bucket_name_suffix = "${local.env}"
}
