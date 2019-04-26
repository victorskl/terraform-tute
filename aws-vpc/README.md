# aws-vpc

AWS VPC Scenarios and Examples:
- https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
- https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenarios.html

There are 3 options:
1. Write up ad-hoc VPC using [`aws_vpc`](https://www.terraform.io/docs/providers/aws/r/vpc.html) and related resources such as `aws_subnet`, `aws_route_table`, `aws_internet_gateway`, etc..
2. Then; you find that you could arrange this ad-hoc code as [terraform module](https://www.terraform.io/docs/modules/index.html), therefore, create and maintain your own VPC module.
3. However; you realize that there are other do like you do and, found many VPC modules in terraform module registry; and over github.

Do [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) unless necessary, so just use:

- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
- https://github.com/terraform-aws-modules/terraform-aws-vpc

### aws-default-vpc

- https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html
- https://aws.amazon.com/premiumsupport/knowledge-center/change-subnet-mask/
- ...
- https://www.terraform.io/docs/providers/aws/r/default_vpc.html
- https://www.terraform.io/docs/providers/aws/r/default_subnet.html
- https://www.terraform.io/docs/providers/aws/r/default_security_group.html
- https://www.terraform.io/docs/providers/aws/d/vpc.html
- https://www.terraform.io/docs/providers/aws/d/subnet_ids.html
- https://www.terraform.io/docs/providers/aws/d/subnet.html
