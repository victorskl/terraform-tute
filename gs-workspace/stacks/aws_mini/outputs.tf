output "workspace" {
  value = "${terraform.workspace}"
}

output "bucket_name" {
  value = "${module.common.bucket_name}"
}
