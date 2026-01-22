# Terraform Test

_aka `tftest.hcl`_

> tl;dr – this is better! support both real and [mock](mock-provider) testing

https://developer.hashicorp.com/terraform/language/tests

```shell
terraform test
```

## GitHub Actions

- https://github.com/hashicorp/setup-terraform

## Assertion

It is HCL expressions on the `condition` keyword for the `assert` block.

- https://developer.hashicorp.com/terraform/language/expressions/conditionals
