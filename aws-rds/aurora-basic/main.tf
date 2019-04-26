terraform {
  required_version = "~> 0.11.6"
}

provider "aws" {
  version = "~> 2.5"
  region  = "${var.region}"
}

provider "random" {
  version = "~> 2.1"
}


//--- using default VPC

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}


//--- rds aurora

module "aurora" {
  source                          = "terraform-aws-modules/rds-aurora/aws"

  name                            = "aurora-example"

  engine                          = "aurora-postgresql"
  engine_version                  = "9.6.9"

  vpc_id                          = "${data.aws_vpc.default.id}"
  subnets                         = ["${data.aws_subnet_ids.all.ids}"]

  replica_count                   = 1
  instance_type                   = "db.r4.large"
  apply_immediately               = true
  skip_final_snapshot             = true

  db_parameter_group_name         = "${aws_db_parameter_group.aurora_db_postgres96_parameter_group.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_postgres96_parameter_group.id}"

  //enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}

resource "aws_db_parameter_group" "aurora_db_postgres96_parameter_group" {
  name        = "test-aurora-db-postgres96-parameter-group"
  family      = "aurora-postgresql9.6"
  description = "test-aurora-db-postgres96-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres96_parameter_group" {
  name        = "test-aurora-postgres96-cluster-parameter-group"
  family      = "aurora-postgresql9.6"
  description = "test-aurora-postgres96-cluster-parameter-group"
}

resource "aws_security_group" "app_servers" {
  name        = "app-servers"
  description = "For application servers"
  vpc_id      = "${data.aws_vpc.default.id}"
}

resource "aws_security_group_rule" "allow_access" {
  type                     = "ingress"
  from_port                = "${module.aurora.this_rds_cluster_port}"
  to_port                  = "${module.aurora.this_rds_cluster_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.app_servers.id}"
  security_group_id        = "${module.aurora.this_security_group_id}"
}
