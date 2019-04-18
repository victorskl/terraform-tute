terraform {
  required_version = "~> 0.11.6"

  backend "consul" {
    address = "demo.consul.io"
    path = "gs-workspace-dooCaifie3Ei"
    lock = false
  }
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
  //source = "../../modules/common"
  source = "github.com:victorskl/terraform-tute//gs-workspace/modules/common"
  bucket_name_suffix = "${local.env}"
}
