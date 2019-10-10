# getting-started

This will be a [steep takeoff](https://www.youtube.com/results?search_query=steep+takeoff)!! You will learn Terraform key fundamental concepts:
1. workspace
2. backend, state and remote state
3. variables
4. modules and code layout (best practices)

### workspace

- https://www.terraform.io/docs/state/workspaces.html
- https://www.terraform.io/docs/enterprise/guides/recommended-practices/part1.html
- https://learn.hashicorp.com/terraform/getting-started/remote
- [Evolving Your Infrastructure with Terraform](https://www.youtube.com/watch?v=wgzgVm7Sqlk)
- [Terraform workspaces and locals for environment separation](https://medium.com/@diogok/terraform-workspaces-and-locals-for-environment-separation-a5b88dd516f5)

### backend, state and remote state

- To avoid S3 backend interactive config, copy `backend.conf.sample` to `_s3.conf` and configure specific settings there. Note that for the first timer, the following resources must be created beforehand.
    - To use a S3 bucket for terraform backend remote state purpose, you may use [S3 Console UI](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/what-is-s3.html) to create it first. Otherwise, you may also use `aws s3api` CLI to provision this. Though our intent is; _Infrastructure-as-a-Code_ but then we still have a _bootstrapping_ situation like this. It is _a classic infrastructure for infrastructure paradox problem_!
    - S3 bucket (with `versioning` enabled) and 
    - DynamoDB table (with `LockID` string as primary key)
    - Then, `terraform init -backend-config="_backend.conf"` to initialize it.
- https://www.terraform.io/docs/backends/index.html
- https://www.terraform.io/docs/backends/config.html
- https://www.terraform.io/docs/backends/types/
- https://www.terraform.io/docs/backends/types/s3.html
- https://www.terraform.io/docs/state/index.html
- https://www.terraform.io/docs/state/remote.html
- [How to: Terraform Locking State in S3](https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6)

### variables

- To avoid `var.region` prompt every time, `export TF_VAR_region=us-west-1`. Otherwise, `unset TF_VAR_region`. Alternatively, copy `terraform.tfvars.sample` to `terraform.tfvars` and configure variables there.
- https://www.terraform.io/docs/commands/environment-variables.html
- https://www.terraform.io/docs/configuration-0-11/variables.html
- https://www.terraform.io/docs/configuration-0-11/locals.html

### modules

- https://www.terraform.io/docs/configuration/modules.html
- https://www.terraform.io/docs/modules/index.html
- https://www.terraform.io/docs/modules/sources.html

### workout

#### prerequisite

- setup [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) and credential
```
pip install awscli
aws configure
aws configure list
```

- setup S3 and DynamoDB table for storing terraform remote state using [aws cli](https://docs.aws.amazon.com/cli/latest/reference/index.html) or Console UI
```
aws s3api create-bucket \
    --bucket gsapp-tf-states \
    --acl private \
    --region ap-southeast-2 \
    --create-bucket-configuration LocationConstraint=ap-southeast-2

(turn on S3 bucket versioning)
aws s3api put-bucket-versioning \
    --bucket gsapp-tf-states \
    --versioning-configuration Status=Enabled

aws dynamodb create-table \
    --table-name gsapp-tf-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

(verify)
aws s3api get-bucket-versioning --bucket gsapp-tf-states
aws s3api get-bucket-acl --bucket gsapp-tf-states
aws s3api list-buckets
aws s3 ls
aws dynamodb list-tables
aws dynamodb describe-table --table-name gsapp-tf-state-lock
```

#### gsapp

The `gsapp` is an example stack which will simply provision a S3 bucket.

```
cd 0-getting-started/stacks/gsapp

(initialise terraform interactively)
terraform init

(initialise terraform using config file)
cp backend.conf.sample _backend.conf
terraform init -backend-config="_backend.conf"

terraform plan
terraform apply

aws s3api list-buckets

terraform workspace new stag
terraform workspace list
terraform plan
terraform apply -auto-approve

aws s3api list-buckets

terraform workspace new prod
terraform workspace list
terraform plan
terraform apply -auto-approve

aws s3api list-buckets

terraform workspace show
terraform workspace select default
terraform output
terraform show
terraform state list
terraform state show module.common.aws_s3_bucket.example
terraform destroy

aws s3api list-buckets

terraform workspace select stag
terraform show
terraform destroy

aws s3api list-buckets

terraform workspace select prod
terraform show
terraform destroy

aws s3api list-buckets

aws s3 ls s3://gsapp-tf-states/
aws s3 ls s3://gsapp-tf-states/gsapp/
aws s3 ls s3://gsapp-tf-states/env:/
aws s3 ls s3://gsapp-tf-states/env:/prod/
aws s3 ls s3://gsapp-tf-states/env:/prod/gsapp/

terraform workspace select default
terraform workspace list

terraform workspace delete stag
aws s3 ls s3://gsapp-tf-states/env:/

terraform workspace delete prod
aws s3 ls s3://gsapp-tf-states/

terraform workspace list
```

#### clean-up

- When done, delete the S3 bucket and DynamoDB for terraform remote state through **Console UI**. Generally deleting through Console UI works out well as it requires to delete all versions of each object that has populated in S3.

- The command line `aws s3api` is too conservative for the clean up job! Due to multiple versions and complain like as follows when you attempt `aws s3api delete-bucket ...` and you will have to perform `aws s3api delete-object ...` on all versions of an object.
    > An error occurred (BucketNotEmpty) when calling the DeleteBucket operation: The bucket you tried to delete is not empty. You must delete all versions in the bucket.

- Alternatively, for this purpose, I have written https://github.com/victorskl/wharfie-aws for S3 clean up operation. Use it if you like.

- If versions of an object is clear, do like so:
```
aws s3api delete-bucket --bucket gsapp-tf-states --region ap-southeast-2
aws dynamodb delete-table --table-name gsapp-tf-state-lock --region ap-southeast-2
rm -rf .terraform
```
