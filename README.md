# terraform-tute

### Installing

```
brew install terraform
terraform version
terraform workspace list
```

### Multiple terraform versions

One way to keep multiple terraform versions on masOS [with brew](https://formulae.brew.sh/formula/terraform) is as follows.

```
brew info terraform
brew info terraform@0.12
brew info terraform@0.11

brew install terraform
terraform version
Terraform v0.13.2

brew install terraform@0.12
alias terraform2="/usr/local/opt/terraform@0.12/bin/terraform"
terraform2 version
Terraform v0.12.29

brew install terraform@0.11
alias terraform1="/usr/local/opt/terraform@0.11/bin/terraform"
terraform1 version
Terraform v0.11.14
```

### Graphing

```
brew info graphviz
brew install graphviz
which dot
dot -V

cd 0-gs-aws
terraform graph
terraform graph | dot -Tpng > graph.png
terraform graph | dot -Tsvg > graph.svg
```
