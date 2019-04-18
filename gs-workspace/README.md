# gs-workspace

```
cd gs-workspace

terraform init
terraform plan
terraform apply

(observe s3 console)
(observe demo.consul.io)

terraform workspace new stag
terraform workspace list
terraform plan
terraform apply

(observe s3 console)
(observe demo.consul.io)

terraform workspace new prod
terraform workspace list
terraform plan
terraform apply

(observe s3 console)
(observe demo.consul.io)

terraform workspace show
terraform workspace select default
terraform output
terraform show
terraform destroy

(observe s3 console)
(observe demo.consul.io)

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

### variables

- To avoid `var.region` prompt every time, `export TF_VAR_region=us-west-1`. Otherwise, `unset TF_VAR_region`.
- https://www.terraform.io/docs/commands/environment-variables.html
- https://www.terraform.io/docs/configuration-0-11/variables.html
- https://www.terraform.io/docs/configuration-0-11/locals.html
