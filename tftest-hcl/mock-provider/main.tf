# main.tf

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
}
