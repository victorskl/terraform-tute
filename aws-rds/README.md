# aws-rds

There are 3 options:
1. Write up ad-hoc RDS using [`aws_db_instance`](https://www.terraform.io/docs/providers/aws/r/db_instance.html) and related resources.
2. Then; you find that you could arrange this ad-hoc code as [terraform module](https://www.terraform.io/docs/modules/index.html), therefore, create and maintain your own RDS module.
3. However; you realize that there are other do like you do and, found many RDS modules in terraform module registry; and over github.

Do [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) unless necessary, so just use:
- https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/1.28.0
- https://github.com/terraform-aws-modules/terraform-aws-rds

Facts:
- https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
- Engine Type [CreateDBInstance](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html):
    - aurora (for MySQL 5.6-compatible Aurora)
    - aurora-mysql (for MySQL 5.7-compatible Aurora)
    - aurora-postgresql
    - mariadb
    - mysql
    - oracle-ee
    - oracle-se2
    - oracle-se1
    - oracle-se
    - postgres
    - sqlserver-ee
    - sqlserver-se
    - sqlserver-ex
- https://aws.amazon.com/rds/pricing/
- https://aws.amazon.com/rds/postgresql/pricing/

### aws-rds-aurora

- https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/1.12.0
- https://github.com/terraform-aws-modules/terraform-aws-rds-aurora
- https://www.terraform.io/docs/providers/aws/r/rds_cluster.html

Facts:
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
- https://aws.amazon.com/rds/aurora/pricing/
- Read aurora support `r4` type only
    - https://github.com/terraform-providers/terraform-provider-aws/issues/2151
    
