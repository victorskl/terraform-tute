# AWS Backup

> See also [aws-rds](../aws-rds)

## TL;DR

Deploying the stack:
```
terraform init
terraform plan
terraform apply
terraform output
```

Connecting to RDS DB instance:
```
psql -h myappdbprod.<xxxxx>.ap-southeast-2.rds.amazonaws.com -U myapp -d myappdbprod
Password for user myapp:
psql (11.5, server 9.6.11)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

myappdbprod=> \l
                                   List of databases
    Name     |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-------------+----------+----------+-------------+-------------+-----------------------
 myappdbprod | myapp    | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres    | myapp    | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 rdsadmin    | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | rdsadmin=CTc/rdsadmin
 template0   | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/rdsadmin          +
             |          |          |             |             | rdsadmin=CTc/rdsadmin
 template1   | myapp    | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/myapp             +
             |          |          |             |             | myapp=CTc/myapp
(5 rows)

myappdbprod=> \q
```

Explore the stack using CLI (or Console UI):
```
aws rds describe-db-instances
aws kms list-aliases
aws kms list-keys
aws kms describe-key --key-id <key-id>
aws backup list-backup-vaults
aws backup list-backup-plans
```

Cleanup:
```
terraform destroy
```


## Recovery Quickstart

Suppose you run your application over ECS and have used RDS DB instance. And you have backup plan for RDS DB instance snapshot using AWS Backup.

There are 4 steps to recovery process.

1. Stop ECS
2. Rename DB instance
3. Restore from the snapshot
4. Start ECS

### 1. Stop ECS

```
aws ecs list-services --cluster myapp-cluster-prod
aws ecs update-service --desired-count 0 --cluster myapp-cluster-prod --service myapp-web-prod
aws ecs update-service --desired-count 0 --cluster myapp-cluster-prod --service myapp-worker-prod
```

This will make ECS service to scale down to 0 tasks; therefore, effectively shutting down myapp containers/tasks. Make sure all running containers/tasks are stopped as follows.

```
aws ecs list-tasks --cluster myapp-cluster-prod --service-name myapp-web-prod
{
    "taskArns": []
}

aws ecs list-tasks --cluster myapp-cluster-prod --service-name myapp-worker-prod
{
    "taskArns": []
}
```

Also make sure to visit https://myapp.frontend.domain.com and check that it should display _503 Service Temporarily Unavailable_. This assume, you front your ECS with [AWS ELB/ALB](../aws-lb) for layer 7 routing. 

### 2. Rename DB instance

Rename existing `myappdbprod` DB instance to `myappdbdel`.

```
aws rds describe-db-instances --db-instance-identifier myappdbprod
aws rds modify-db-instance --db-instance-identifier myappdbprod --new-db-instance-identifier myappdbdel --apply-immediately
aws rds describe-db-instances
```

### 3. Restore from snapshot

First, determine the snapshot identifier to recover from. Probably sort by timestamp and note down the `DBSnapshotIdentifier`. For example.
```
aws rds describe-db-snapshots
  ...
  "DBSnapshotIdentifier": "awsbackup:job-66de8820-dc2f-4948-9a1b-8c4d6a4e91b0"
  ...
```

Then, run restore from DB snapshot command as follows.
```
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier myappdbprod \
  --db-snapshot-identifier awsbackup:job-66de8820-dc2f-4948-9a1b-8c4d6a4e91b0 \
  --vpc-security-group-ids sg-0993ba0e942e9cc99 \
  --db-subnet-group-name myappdbprod-20190929232242395400000002 \
  --db-parameter-group-name myappdbprod-20190929232242385100000001 \
  --no-publicly-accessible \
  --enable-cloudwatch-logs-exports "postgresql" "upgrade"
```

Wait for any pending changes and DB instance status come back to **Available**.
```
aws rds describe-db-instances --db-instance-identifier myappdbprod | grep Pending
aws rds describe-db-instances --db-instance-identifier myappdbprod | grep DBInstanceStatus
            "DBInstanceStatus": "available",
```

Optionally, for DB instance configuration parameters, VPC, DB security group, etc, you can recall from previous DB instance `myappdbdel` as follows.
```
aws rds describe-db-instances --db-instance-identifier myappdbdel > left.json
```
And check again the newly created/restored DB instance from the snapshot.
```
aws rds describe-db-instances --db-instance-identifier myappdbprod > right.json

diff left.json right.json
```

### 4. Start ECS

Finally, bring up the myapp containers as follows. Basically undo the Step 1.

```
aws ecs update-service --desired-count 1 --cluster myapp-cluster-prod --service myapp-web-prod
aws ecs update-service --desired-count 1 --cluster myapp-cluster-prod --service myapp-worker-prod
```


## Overview 

- https://aws.amazon.com/backup/
- https://aws.amazon.com/about-aws/whats-new/2019/04/introducing-aws-backup/
- https://aws.amazon.com/blogs/aws/aws-backup-automate-and-centrally-manage-your-backups/

### Summary

- Centrally manage and automate backups across AWS services
- Supported services:
    - EBS
    - RDS database engines ([except Amazon Aurora][1])
    - DynamoDB
    - EFS
    - Storage Gateway

### Pricing

- Refer to pricing table: https://aws.amazon.com/backup/pricing/
- At the moment, only EFS backups can be transition into Cold Storage (Glacier, perhaps). All other backups are in Warm Storage. It is speculated that underlying AWS Backup storage mechanism is [backed by S3 but hidden from direct management by a user](https://medium.com/@kenhuiny/digging-into-the-new-aws-backup-service-52b993be4ded).

### Key steps

1. Create a IAM role for backup and restore purpose
2. Create a backup vault
3. Create a backup plan
    - create rules
        - cron schedule
        - lifecycle
4. Tie all together in **Resource assignments** 

#### Resource assignments

Resource assignments policy can be designed and strategized into two approaches:
1. [tagged][2] resources (_cross-cutting concerns_ among organization-wise resources)
2. specific resources (_deterministic_ to project by project basis)

### Operation

There are two modes of operation. 

1. [Create a Scheduled Backup][3]
2. [Create an On-Demand Backup][4]

Both setup can be achieved through Console UI. However, it is recommended to create a Scheduled Backup through terraform. And, operate an On-Demand Backup through `awscli` (or Python script it for _codifying_ purpose).

[1]: https://docs.aws.amazon.com/aws-backup/latest/devguide/getting-started.html
[2]: https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html
[3]: https://docs.aws.amazon.com/aws-backup/latest/devguide/create-a-scheduled-backup.html
[4]: https://docs.aws.amazon.com/aws-backup/latest/devguide/create-on-demand-backup.html


## Terraform

### Creating a scheduled backup

- First create a [`aws_iam_role`][t1] for backup and restore purpose. Next, attach two AWS managed policies  `AWSBackupServiceRolePolicyForBackup` and `AWSBackupServiceRolePolicyForRestores` to the role with [`aws_iam_role_policy_attachment`][t2].
- Then, create a [`aws_backup_vault`][t3].
- And, create a [`aws_backup_plan`][t4].
- Finally, tie all together with [`aws_backup_selection`][t5].

[t1]: https://www.terraform.io/docs/providers/aws/r/iam_role.html
[t2]: https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
[t3]: https://www.terraform.io/docs/providers/aws/r/backup_vault.html
[t4]: https://www.terraform.io/docs/providers/aws/r/backup_plan.html
[t5]: https://www.terraform.io/docs/providers/aws/r/backup_selection.html

The following is an example ***Scheduled Backup*** code snippet for setting up **Monthly** backup with **6-months** retention period for a RDS DB instance.

```
resource "aws_iam_role" "db_backup_role" {
  name               = "stack_env_backup_restore_role"
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

  tags = "..."
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
  name        = "stack_env_backup_vault"
  kms_key_arn = "${data.terraform_remote_state.infra.rds_shared_kms_arn}"
  tags        = "..."
}

resource "aws_backup_plan" "db_backup_plan" {
  name = "stack_env_backup_plan"

  rule {
    rule_name         = "Monthly"
    target_vault_name = "${aws_backup_vault.db_backup_vault.name}"
    schedule          = "cron(0 3 1 * ? *)"
    
    // expires snapshots after 6 months
    lifecycle {
      delete_after = 180
    }
  }

  tags = "..."
}

resource "aws_backup_selection" "db_backup" {
  name         = "stack_env_backup"
  plan_id      = "${aws_backup_plan.db_backup_plan.id}"
  iam_role_arn = "${aws_iam_role.db_backup_role.arn}"

  // an example RDS DB instance ARN
  resources = [
    "${module.db.this_db_instance_arn}",
  ]
}
```

#### Cron expression

For cron expression, it can refer to [CloudWatch schedule event](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html) syntax.

Example: Monthly

- Run at 3:00 am (UTC) every 1st day of the month 
    ```
    cron(0 3 1 * ? *)
    ```

### Restoring DB snapshot with terraform

- Note that, recovering from the snapshot normally create new DB resource. Therefore, terraform will perform destroy and recreate DB resource.
- For example, in the following code snippet, when `restore_from_snapshot` and `snapshot_identifier` conditional variables are defined, terraform will destroy and recreate the RDS DB instance from the provided snapshot identifier. 
    ```
    module "db" {
      source = "terraform-aws-modules/rds/aws"
      version = "1.28.0"
    
      snapshot_identifier = "${var.restore_from_snapshot ? var.snapshot_identifier : ""}"
      ...
      ...
    }
    ```
- You can get the value of `snapshot_identifier` variable from the backup vault through Console UI or through RDS CLI (see next section). Example as follows. 
    ```
    restore_from_snapshot = true
    snapshot_identifier   = "awsbackup:job-55de7720-dc2f-4948-9a1b-8c4d6a4e91b0"  
    ```

## On-Demand Backup through CLI

- As discussed, we can use AWS CLI [`aws backup`](https://docs.aws.amazon.com/cli/latest/reference/backup/index.html) to perform on-demand snapshot. 
- It is preferable to provision a backup vault, plan, etc... through terraform whenever possible as described in previous section.
- The following is the replay of `aws backup` CLI commands that discover the already provisioned backup by terraform and, perform an on-demand backup over it.

```
aws backup list-backup-jobs
aws backup list-backup-vaults
aws backup describe-backup-vault --backup-vault-name myappdbprod_backup_vault
aws backup list-backup-plans
aws backup get-backup-plan --backup-plan-id <backup-plan-id>
aws backup list-backup-selections --backup-plan-id <backup-plan-id>
aws backup get-backup-selection --backup-plan-id <backup-plan-id> --selection-id <selection-id>

aws backup start-backup-job \
    --backup-vault-name myappdbprod_backup_vault \
    --resource-arn arn:aws:rds:ap-southeast-2:123456789012:db:myappdbprod \
    --iam-role-arn arn:aws:iam::123456789012:role/myappdbprod_backup_role

aws backup list-backup-jobs
aws backup list-protected-resources
aws backup list-recovery-points-by-backup-vault --backup-vault-name myappdbprod_backup_vault --max-results 30
```

- Also verify that the backup show up in RDS snapshots

(RDS Console > Snapshots > At drop-down 'Owned by Me' to 'Backup service')

```
aws rds describe-db-snapshots
```

## Caveats

- It is inevitable that the recovery operation will incur downtime. Usually, the recovery time is directly related to the size of data that need to be restored. This has to workout with SLA and recovery time objective (RTO). The recovery point objective (RPO) also has to line up with the granularity of the schedule policy.
- **Backup and Restore** through AWS Backup can be used as a baseline low cost Disaster Recovery solution to some extent.
