#!/usr/bin/env bash

mkdir -p examples
mkdir -p test

rm -rf examples/*
rm -rf test/*

wget -P examples https://raw.githubusercontent.com/gruntwork-io/terratest/refs/heads/main/examples/terraform-basic-example/README.md
wget -P examples https://raw.githubusercontent.com/gruntwork-io/terratest/refs/heads/main/examples/terraform-basic-example/main.tf
wget -P examples https://raw.githubusercontent.com/gruntwork-io/terratest/refs/heads/main/examples/terraform-basic-example/outputs.tf
wget -P examples https://raw.githubusercontent.com/gruntwork-io/terratest/refs/heads/main/examples/terraform-basic-example/varfile.tfvars
wget -P examples https://raw.githubusercontent.com/gruntwork-io/terratest/refs/heads/main/examples/terraform-basic-example/variables.tf

wget -P test https://raw.githubusercontent.com/gruntwork-io/terratest/refs/heads/main/test/terraform_basic_example_test.go
