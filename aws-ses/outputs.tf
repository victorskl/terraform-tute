output "email_user" {
  value = "${aws_iam_access_key.smtp_user_access_key.id}"
}

output "email_password" {
  value = "${aws_iam_access_key.smtp_user_access_key.ses_smtp_password}"
}
