terraform {
  required_version = "~> 0.11.6"
}

provider "aws" {
  version = "~> 2.6"
  region  = "${var.region}"
}

provider "random" {
  version = "~> 2.1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "http" "myip" {
  url = "https://domains.google.com/checkip"
}

resource "aws_security_group" "rds_sg" {
  name = "${var.stack}-${var.env_name}-rds-sg"
  description = "RDS Trusted Security Group created by ${var.stack}-${var.env_name}"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  // https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map("Name", "${var.stack}-${var.env_name}-rds-sg"))}"
}

resource "random_string" "master_password" {
  length = 32
  special = false
}

resource "aws_ssm_parameter" "master_password" {
  count = "${var.restore_from_snapshot ? 0 : 1}"
  name  = "/${var.stack}/${var.env_name}/database/master_password"
  type  = "SecureString"
  value = "${random_string.master_password.result}"
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "1.28.0"

  snapshot_identifier = "${var.restore_from_snapshot ? var.snapshot_identifier : ""}"

  identifier = "${var.stack}db${var.env_name}"
  name = "${var.stack}db${var.env_name}"
  username = "${var.stack}"
  password = "${join("",aws_ssm_parameter.master_password.*.value)}"

  publicly_accessible = true

  instance_class = "${var.db_instance_class}"
  allocated_storage = "${var.db_allocated_storage}"

  port = "5432"
  engine = "postgres"
  engine_version = "9.6.11"
  major_engine_version = "9.6"
  family = "postgres9.6"

  subnet_ids = ["${data.aws_subnet_ids.all.ids}"]
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window = "03:00-06:00"
  backup_retention_period = 0

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = "${merge(var.default_tags, map("Name", "${var.stack}db${var.env_name}"))}"
}


//--- RDS database snapshot backup using AWS Backup

resource "aws_iam_role" "db_backup_role" {
  name               = "${var.stack}db${var.env_name}_backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY

  tags = "${merge(var.default_tags, map("Name", "${var.stack}db${var.env_name}"))}"
}

resource "aws_iam_role_policy_attachment" "db_backup_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = "${aws_iam_role.db_backup_role.name}"
}

resource "aws_iam_role_policy_attachment" "db_backup_role_restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = "${aws_iam_role.db_backup_role.name}"
}

resource "aws_backup_vault" "db_backup_vault" {
  name        = "${var.stack}db${var.env_name}_backup_vault"
  kms_key_arn = "${aws_kms_key.rds_key.arn}"
  tags        = "${merge(var.default_tags, map("Name", "${var.stack}db${var.env_name}"))}"
}

resource "aws_backup_plan" "db_backup_plan" {
  name = "${var.stack}db${var.env_name}_backup_plan"

  // Backup weekly and keep it for 6 weeks
  // Cron At 17:00 on every Sunday UTC = AEST/AEDT 3AM/4AM on every Monday
  rule {
    rule_name         = "Weekly"
    target_vault_name = "${aws_backup_vault.db_backup_vault.name}"
    schedule          = "cron(0 17 ? * SUN *)"

    lifecycle {
      delete_after = 42
    }
  }

  tags = "${merge(var.default_tags, map("Name", "${var.stack}db${var.env_name}"))}"
}

resource "aws_backup_selection" "db_backup" {
  name         = "${var.stack}db${var.env_name}_backup"
  plan_id      = "${aws_backup_plan.db_backup_plan.id}"
  iam_role_arn = "${aws_iam_role.db_backup_role.arn}"

  resources = [
    "${module.db.this_db_instance_arn}",
  ]
}


//--- Optional KMS RDS server-side encryption key that is used to protect your backups

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "rds_kms_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.current.arn}"]
    }
    resources = ["*"]
    actions   = ["kms:*"]
  }
}

resource "aws_kms_key" "rds_key" {
  description = "${var.stack} RDS key in ${var.region}"
  policy      = "${data.aws_iam_policy_document.rds_kms_policy.json}"
  tags        = "${merge(var.default_tags, map("Name", "${var.stack}db${var.env_name}"))}"
}

resource "aws_kms_alias" "prod_rds_key" {
  name          = "alias/${var.stack}-${var.env_name}-rds"
  target_key_id = "${aws_kms_key.rds_key.key_id}"
}
