terraform {
  required_version = "~> 0.11.14"
}

provider "aws" {
  region  = "ap-southeast-2"
}

data "aws_vpc" "default" {
  default = true
}

# Example how to query back created private subnets using tag filter: Tier = "private"
data "aws_subnet_ids" "private_subnets" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Tier = "private"
  }
}

output "private_subnets" {
  value = "${data.aws_subnet_ids.private_subnets.ids}"
}

# --- Example use case
# Say, your app run integration test (IT) during CodeBuild/CodePipeline and
# pull source from GitHub + some depedencies from Internet package repo.
# Then, when run IT test cases, your app also need to connect RDS isolated in private subnet.

/*
resource "aws_codebuild_project" "myapp_api" {
  name = "myapp-api-codebuild"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:2.0"
    type = "LINUX_CONTAINER"

    environment_variable {
      name = "STAGE"
      value = "${terraform.workspace}"
    }

    environment_variable {
      name = "API_DOMAIN_NAME"
      value = "${local.api_domain}"
    }
  }

  vpc_config {
    vpc_id = "${data.aws_vpc.default.id}"
    subnets = ["${data.aws_subnet_ids.private_subnets.ids}"]
    security_group_ids = ["${aws_security_group.codebuild_security_group.id}"]
  }
}

resource "aws_db_subnet_group" "rds" {
  name = "db_subnet_group"
  subnet_ids = ["${data.aws_subnet_ids.private_subnets.ids}"]
}

resource "aws_rds_cluster" "db" {
  cluster_identifier  = "myapp-aurora-cluster"
  engine              = "aurora"
  engine_mode         = "serverless"
  skip_final_snapshot = true

  database_name   = "myapp-db"
  master_username = "${data.aws_ssm_parameter.rds_db_username.value}"
  master_password = "${data.aws_ssm_parameter.rds_db_password.value}"

  vpc_security_group_ids = ["${aws_security_group.rds_security_group.id}"]

  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"

  scaling_configuration {
    auto_pause = true
  }
}

resource "aws_security_group" "rds_security_group" {
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "myapp_rds_sg"
  description = "Allow inbound traffic for RDS MySQL"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"

    # Allowing codebuild (intergation tests) to access RDS
    security_groups = [
      "${aws_security_group.codebuild_security_group.id}",
      "... might have more app security group id here",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/
