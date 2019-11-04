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

## Accessing RDS databases

Reading:
- [Scenarios for Accessing a DB Instance in a VPC](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.Scenarios.html)
- [Connecting to a DB Instance Running the PostgreSQL Database Engine](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToPostgreSQLInstance.html)
- [Working with a DB Instance in a VPC](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html)

### Key points

- You need adjust two configurations
    1. Public accessibility
    2. Security groups (aka Firewall rules) to allow Ingress

### Security Group

> AWS Console > EC2 > Security Groups > select RDS DB instance security group > add Inbound/Ingress rule

- Allow ingress rule in security group that attach to the DB instance.
- Remember to use `My IP` at `Source` column to get current IP, if you plan to connect it from your laptop/workstation. Otherwise, you should limit to specific subnet that you wish to connect from.

### Public accessibility

> AWS Console > RDS > select DB Instance > Security > Public accessibility > No/Yes

- Select Yes if you want EC2 instances and devices outside of the VPC hosting the DB instance to connect to the DB instance.
- If you select No, Amazon RDS will not assign a public IP address to the DB instance, and no EC2 instance or devices outside of the VPC will be able to connect. 
- If you select Yes, you must also select one or more VPC security groups that specify which EC2 instances and devices can connect to the DB instance. EC2 instances and devices outside of the VPC hosting the DB instance will connect to the DB instances. 

However, allowing `Public Accessibility` is not always needed and, not best practice! You should have EC2 _bastion host_ spin up in the same VPC as DB instance and, access your RDS DB instance from there. Or, make a DB dump to S3 bucket and reconstruct it in your local desktop. Other option includes [Amazon Workspaces](https://aws.amazon.com/workspaces/). 

> If you ever need to enable `Public Accessibility` for debugging purpose then make sure to disable back after use. 


## Operational

### Storage

- Read [Amazon RDS DB Instance Storage](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html)
    - Use Amazon Elastic Block Store (Amazon EBS) volumes for database and log storage
    - MySQL, MariaDB, and PostgreSQL, Oracle RDS DB instances - up to 64 TiB 
    - SQL Server - 16 TiB

### Multi-AZ deployments

- Read [Regions and Availability Zones](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)
    - Each AWS Region is a separate geographic area
    - Each AWS Region has multiple, isolated locations known as _Availability Zones_.
    - Usually 3 zones: `ap-southeast-2a:2b:2c`
- Read [High Availability (Multi-AZ) for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)
    - **Standby** replica (_failover_) Vs **Read-only** replica (_throughput_)
    - The RDS console shows the Availability Zone of the standby replica (called the secondary AZ)
    - AWS is engineered with low-latency network connectivity between Availability Zones
    - A DB instance in a Single-AZ deployment can modify it to be a Multi-AZ deployment (for engines other than SQL Server or Amazon Aurora)
    - Failover times are typically 60-120 seconds (but it also depends on the database activity and other conditions at the time the primary DB instance became unavailable)
    - Need to re-establish any existing connections to your DB instance

### Serverless

Say, you are creating a RDBMS cluster either by: 

1. creating a bunch of EC2 instances, install your choice of RDBMS and network/cluster them up together yourself (_good old classic approach!_)

2. or creating a bunch of `aws_db_instance` resources and network them up together yourself (_only in principal, don't do it!_)

3. or creating [High Availability (Multi-AZ) for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html), of which in terraform equivalent, resource creation `aws_db_instance` with [`multi_az`](https://www.terraform.io/docs/providers/aws/r/db_instance.html#multi_az) flag (also the same flag if using [module](https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/1.28.0#inputs)). 

Anyhow, you will end up a few db instances up and running in a cluster. Depends on stochastic user load, there might be a need for scaling up or down of these db instances. You might also want to autonomously mange on these scaling events. This is something to reckon with [AWS Auto Scaling](https://aws.amazon.com/autoscaling/). 

If you can limit yourself with Aurora service, it provides a feature engine mode [`serverless`](https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#engine_mode). With `serverless` mode, you can forget about how Aurora will be scaling and focus on your development. Theoretically, (if no user load or) it should bill per-request or per-query execution level with set minimum threshold for charges. However, cons are Cold start Vs Warm start and, how your App compensate on this. Great for testing/development purpose though! Production, ummm, autoscaling might have a bit more control, I reckon!

- https://aws.amazon.com/rds/aurora/serverless/
- https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.html

Articles:
- [Aurora Serverless: The Good, the Bad and the Scalable](https://www.jeremydaly.com/aurora-serverless-the-good-the-bad-and-the-scalable/)
- [Up and running with Aurora Serverless](https://lobster1234.github.io/2019/04/22/serverless-aurora-rds/)
- [Amazon Aurora Serverless — Features, Limitations, Glitches](https://medium.com/searce/amazon-aurora-serverless-features-limitations-glitches-d07f0374a2ab)

### Autoscaling

Alternatively, you could also use the managed Aurora service `aws_rds_cluster` with [Application Autoscaling](https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html) `aws_appautoscaling_target`, `aws_appautoscaling_policy` as example in [Aurora Read Replica Autoscaling](https://www.terraform.io/docs/providers/aws/r/appautoscaling_policy.html#aurora-read-replica-autoscaling). 

Depends on situation, deploying this way might be a bit more complex but has more control. Highly recommend to utilise the Aurora module [here](https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/1.12.0), [here](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/blob/v1.12.0/examples/advanced/main.tf) and [here](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora/blob/v1.12.0/main.tf#L105) for starter!

>Note though, **Stateful** autoscaling is always challenging in practise!


## Backup

Reading:
- [Amazon RDS Backup and Restore](https://aws.amazon.com/rds/details/backup/)
- [Working With Backups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html)

### Type of backups
- Your Amazon RDS backup storage for each region is composed of 
    1. the **automated backups** and 
    2. **manual DB snapshots** for that region.
- See [Automatic Backups and Database Snapshots](https://aws.amazon.com/rds/faqs/#Automatic_Backups_and_Database_Snapshots) FAQ for differences.

### Backup storage    
- Your backup storage is equivalent to the sum of the database storage for all instances in that region.
- There is [no additional charge](https://aws.amazon.com/rds/postgresql/pricing/) for backup storage up to 100% of your total database storage for a region.
    > For example, if you have an active PostgreSQL instance with 500 GiB-month of provisioned database storage and an active MySQL DB instance with 200 GiB-month of provisioned database storage, we provide up to 700 GiB-month of backup storage at no additional charge.
- After the DB instance is terminated, backup storage is billed at `$0.095` per GiB-month.
- Additional backup storage is `$0.095` per GiB-month.
- By default, Amazon RDS creates and saves automated backups of your DB instance securely in [Amazon S3](https://aws.amazon.com/rds/details/backup/) for a user-specified retention period.
- Database snapshots are user-initiated backups of your instance [stored in Amazon S3](https://aws.amazon.com/rds/details/backup/) that are kept until you explicitly delete them. 
- You can create a new instance from a database snapshots whenever you desire.

### Automated backups
- **Automated backups** occur **DAILY** during the **preferred backup window**. If the backup requires more time than allotted to the backup window, the backup continues after the window ends, until it finishes.
- The backup window can't overlap with the weekly maintenance window for the DB instance.
- The first (automated backup) snapshot of a DB instance contains the data for the full DB instance. Subsequent snapshots of the same DB instance are incremental. Offer fine grain Point-In-Time recovery.
- **Backup retention period** can be set between 0 and 35 days when you create a DB instance.
- Setting the backup retention period to 0 disables automated backups.
- An outage occurs if you change the backup retention period from 0 to a non-zero value or from a non-zero value to 0.

### Manual snapshots
- You can create manual DB snapshot at any point in time through RDS Console UI or CLI or [AWS Backup](../aws-backup).
- RDS backups through [AWS Backup](../aws-backup) mechanism also are treated as _manual_ snapshots.
- These manual (user-initiated) snapshots are always full DB instance backups, contrary to incremental in automated backups. _(By observation)_


### TL;DR RDS backups

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

### Recovery

There are 3 options to [restore RDS databases](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_CommonTasks.BackupRestore.html):

1. [Restoring from a DB Snapshot](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html) -- [`aws rds restore-db-instance-from-db-snapshot help`](https://docs.aws.amazon.com/cli/latest/reference/rds/restore-db-instance-from-db-snapshot.html)
    
2. [Restoring a DB Instance to a Specified Time](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html) -- [`aws rds restore-db-instance-to-point-in-time help`](https://docs.aws.amazon.com/cli/latest/reference/rds/restore-db-instance-to-point-in-time.html)

3. [Restore DB instance from S3](https://docs.aws.amazon.com/cli/latest/reference/rds/restore-db-instance-from-s3.html)

Note though that **Point-in-Time Recovery** is only available when you have enabled automated backups option. If you have only performed snapshot backups (this include AWS Backup -- because AWS Backup perform a snapshot backup as background service i.e. `"SnapshotType": "awsbackup"`), then you can only do restore from a DB snapshot.

Also [note these](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html):
> * Amazon RDS creates a storage volume snapshot of your DB instance, backing up the entire DB instance and not just individual databases. 
> * You can't restore from a DB snapshot to an existing DB instance; a new DB instance is created when you restore.

There are few recovery strategies:

* Restore from a snapshot which will create a new RDS DB instance, then update your Application config to reflect this new RDS DB instance endpoint. _(you don't want this!)_
* [Create a new RDS DB instance with temporary name](https://stackoverflow.com/questions/24278220/amazon-rds-restore-snapshot-to-existing-instance), create a SQL dump from this temporary DB instance, then restore it into the original DB instance.
* Stop all connections to master DB instance, [rename original DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RenameInstance.html#USER_RenameInstance.RR) and, [name the new DB instance with original name](https://aws.amazon.com/blogs/aws/endpoint-renaming-for-amazon-rds/) and restore it from the snapshot.

Also [note that](https://acloud.guru/forums/aws-certified-solutions-architect-associate/discussion/-KcVAbXwQAAoB17SNyPw/why_restoring_the_from_a_snaph):
> * Apart from the name you assign the instance, the endpoint will remain the same - the 'random' string in it is tied to your account.

```
mydbinstancename.<account-wise-random-string>.<region>.rds.amazonaws.com
```

