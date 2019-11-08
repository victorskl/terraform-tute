output "myip" {
  value = "${data.http.myip.body}"
}

output "master_password" {
  value = "${aws_ssm_parameter.master_password.*.value}"
}

output "this_db_instance_endpoint" {
  value = "${module.db.this_db_instance_endpoint}"
}

output "this_db_instance_name" {
  value = "${module.db.this_db_instance_name}"
}
