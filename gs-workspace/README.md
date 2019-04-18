# gs-workspace

```
cd gs-workspace

terraform init
terraform plan
terraform apply

(observe s3 console)

terraform workspace new stag
terraform workspace list
terraform plan
terraform apply

(observe s3 console)

terraform workspace new prod
terraform workspace list
terraform plan
terraform apply

(observe s3 console)

terraform workspace show
terraform workspace select default
terraform output
terraform show
terraform destroy

(observe s3 console)

terraform workspace select stag
terraform show
terraform destroy

terraform workspace select prod
terraform show
terraform destroy

terraform workspace select default
terraform workspace list
terraform workspace delete stag
terraform workspace delete prod
terraform workspace list
```

- https://www.terraform.io/docs/enterprise/guides/recommended-practices/part1.html
- https://learn.hashicorp.com/terraform/operations/maintaining-multiple-environments
- [Evolving Your Infrastructure with Terraform](https://www.youtube.com/watch?v=wgzgVm7Sqlk)
- [Terraform workspaces and locals for environment separation](https://medium.com/@diogok/terraform-workspaces-and-locals-for-environment-separation-a5b88dd516f5)

### modules

- https://www.terraform.io/docs/configuration/modules.html
- https://www.terraform.io/docs/modules/index.html
- https://www.terraform.io/docs/modules/sources.html

### backend

- To avoid s3 backend interactive config, copy `backend.conf.sample` to `_s3.conf` and configure specific settings there. Note that for first timer, both s3 bucket (with `versioning` enabled) and dynamo db table (with `LockID` string as primary key) must be created prior (one time effort, therefore, use console UI to create them). Then, `terraform init -backend-config="_s3.conf"` to initialize it.
- https://www.terraform.io/docs/backends/config.html
- https://www.terraform.io/docs/backends/types/
- https://www.terraform.io/docs/backends/types/s3.html

### variables

- To avoid `var.region` prompt every time, `export TF_VAR_region=us-west-1`. Otherwise, `unset TF_VAR_region`. Alternatively, copy `terraform.tfvars.sample` to `terraform.tfvars` and configure variables there.
- https://www.terraform.io/docs/commands/environment-variables.html
- https://www.terraform.io/docs/configuration-0-11/variables.html
- https://www.terraform.io/docs/configuration-0-11/locals.html
