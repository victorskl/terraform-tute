# aws-rds

Remember:
- In conventional setup, we can run a RDBMS in a **standalone** or **cluster**  mode.
- In terraform for AWS _managed_ RDBMS services, this concept basically apply into `aws_db_instance` and `aws_rds_cluster` resources respectively. And `aws_rds_cluster` is a synonym to Amazon Aurora.

Engine:
- Engine Type API: [CreateDBInstance](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html):
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
- These goes to terraform `aws_db_instance` resource [engine](https://www.terraform.io/docs/providers/aws/r/db_instance.html#engine) flag and `aws_rds_cluster` resource [engine](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#engine) flag. Note that `aws_rds_cluster` resource engine flag only accept `aurora`, `aurora-mysql`, `aurora-postgresql`. (Recall: therefore a synonym to Aurora service only). If you are creating any _aurora-ish_ engine type, you are as well be creating a `aws_rds_cluster`.

DBInstanceClass:
- https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
- Note that Aurora only support `r3`, `r4`, `r5` and `t2`, `t3` classes.

Pricing:
- https://aws.amazon.com/rds/pricing/

### aws_db_instance

There are 3 possibilities:

1. Write up RDS resource creation using [`aws_db_instance`](https://www.terraform.io/docs/providers/aws/r/db_instance.html) and, for related resources.
2. Then; you find that you could arrange this ad-hoc code as [terraform module](https://www.terraform.io/docs/modules/index.html), therefore, create and maintain your own RDS terraform module.
3. However; you realize that there are other do like you do and, found many (well maintain and coded) RDS modules in terraform module registry; and over github.

Verdict: Do [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) unless necessary, so just use:
- https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/1.28.0
- https://github.com/terraform-aws-modules/terraform-aws-rds


### aws_rds_cluster 
(aka aurora)

Similarly for Aurora; you could write from scratch using [`aws_rds_cluster`](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html) and related resources. But just simply use the following module.

- https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/1.12.0
- https://github.com/terraform-aws-modules/terraform-aws-rds-aurora

### serverless

When you are creating RDBMS cluster either by: 
1. creating a bunch of `aws_db_instance` resources and network them up together yourself 
2. or using managed Aurora service through creating `aws_rds_cluster` resource

You will end up a few db instances up and running in a cluster. Depends on stochastic user load, there might be a need for scaling up or down of these db instances. You might also want to autonomously mange on these scaling events. This is something to reckon with [AWS Auto Scaling](https://aws.amazon.com/autoscaling/). 

However, if you can limit yourself with Aurora service, it provides this feature with [engine mode `serverless`](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#engine_mode).

- https://aws.amazon.com/rds/aurora/serverless/
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.html

Articles:
- [Aurora Serverless: The Good, the Bad and the Scalable](https://www.jeremydaly.com/aurora-serverless-the-good-the-bad-and-the-scalable/)
- [Up and running with Aurora Serverless](https://lobster1234.github.io/2019/04/22/serverless-aurora-rds/)
- [Amazon Aurora Serverless — Features, Limitations, Glitches](https://medium.com/searce/amazon-aurora-serverless-features-limitations-glitches-d07f0374a2ab)

## backup

### Reading
- [Amazon RDS Backup and Restore](https://aws.amazon.com/rds/details/backup/)
- [Working With Backups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html)

### Key points

#### type of backups
- Your Amazon RDS backup storage for each region is composed of 
    1. the **automated backups** and 
    2. **manual DB snapshots** for that region.

#### storage    
- Your backup storage is equivalent to the sum of the database storage for all instances in that region.
- There is [no additional charge](https://aws.amazon.com/rds/postgresql/pricing/) for backup storage up to 100% of your total database storage for a region.
    > For example, if you have an active PostgreSQL instance with 500 GiB-month of provisioned database storage and an active MySQL DB instance with 200 GiB-month of provisioned database storage, we provide up to 700 GiB-month of backup storage at no additional charge.
- After the DB instance is terminated, backup storage is billed at `$0.095` per GiB-month.
- Additional backup storage is `$0.095` per GiB-month.
- By default, Amazon RDS creates and saves automated backups of your DB instance securely in [Amazon S3](https://aws.amazon.com/rds/details/backup/) for a user-specified retention period.
- Database snapshots are user-initiated backups of your instance [stored in Amazon S3](https://aws.amazon.com/rds/details/backup/) that are kept until you explicitly delete them. 
- You can create a new instance from a database snapshots whenever you desire.

#### snapshots
- The first snapshot of a DB instance contains the data for the full DB instance. Subsequent snapshots of the same DB instance are incremental.

#### automated backups
- **Automated backups** occur **DAILY** during the **preferred backup window**. If the backup requires more time than allotted to the backup window, the backup continues after the window ends, until it finishes.
- The backup window can't overlap with the weekly maintenance window for the DB instance.

#### retention period
- **Backup retention period** can be set between 0 and 35 days when you create a DB instance.
- Setting the backup retention period to 0 disables automated backups.
- An outage occurs if you change the backup retention period from 0 to a non-zero value or from a non-zero value to 0.

### tl;dr

So.

By default, RDS _built-in_ automated backup and retention gives you, a daily database backup with retention (keep the backup) upto maximum 35 days. Then, it will expires (rotate) from the oldest in the backups stack, probably.

In terraform these translate to setting up two arguments:

For `aws_db_instance`:
1. [backup_window](https://www.terraform.io/docs/providers/aws/r/db_instance.html#backup_window)
2. [backup_retention_period](https://www.terraform.io/docs/providers/aws/r/db_instance.html#backup_retention_period)

For `aws_rds_cluster`:
1. [preferred_backup_window](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#preferred_backup_window)
2. [backup_retention_period](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#backup_retention_period)

So. 

What if, we wanted to have a specific backup schedule policy? Say, monthly backups with 6 months rotation. We could write a custom script (probably in Python with Boto) to create/execute a RDS DB snapshot at specific schedule time. The script could be outside of AWS (i.e. remotely executing through API) or [Lambda with EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/what-is-amazon-eventbridge.html).

However.

For most cases, you should utilise [AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html) for a more streamlined centralized consolidated backups. For this, peak into [aws-backup](../aws-backup).
