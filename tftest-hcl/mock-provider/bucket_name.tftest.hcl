# bucket_name.tftest.hcl

mock_provider "aws" {}

run "sets_correct_name" {
  variables {
    bucket_name = "my-bucket-name"
  }

  assert {
    condition     = aws_s3_bucket.my_bucket.bucket == "my-bucket-name"
    error_message = "incorrect bucket name"
  }
}
