# aws-rds

There are 3 options:
1. Write up ad-hoc RDS using [`aws_db_instance`](https://www.terraform.io/docs/providers/aws/r/db_instance.html) and related resources.
2. Then; you find that you could arrange this ad-hoc code as [terraform module](https://www.terraform.io/docs/modules/index.html), therefore, create and maintain your own RDS module.
3. However; you realize that there are other do like you do and, found many RDS modules in terraform module registry; and over github.

Do [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) unless necessary, so just use:
- https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/1.28.0
- https://github.com/terraform-aws-modules/terraform-aws-rds

Pricing and Type:
- https://aws.amazon.com/rds/postgresql/pricing/
- https://aws.amazon.com/rds/aurora/pricing/
