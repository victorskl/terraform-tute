//--- Create an IAM User for SES SMTP

terraform {
  required_version = "~> 0.11.6"
}

provider "aws" {
  version = "~> 2.5"
  region = "${var.region}"
}

// See https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html for policy statement
data "aws_iam_policy_document" "smtp_send_policy" {
  statement {
    effect = "Allow"
    actions = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_user" "smtp_iam_user" {
  name = "${var.smtp_iam_user_name}"
}

resource "aws_iam_user_policy" "smtp_user_policy" {
  policy = "${data.aws_iam_policy_document.smtp_send_policy.json}"
  user = "${aws_iam_user.smtp_iam_user.name}"
}

resource "aws_iam_access_key" "smtp_user_access_key" {
  user = "${aws_iam_user.smtp_iam_user.name}"
}
