# default-vpc-plus

Turn default VPC topology to 2-tier layer architecture:
- by adding 3 more private subnets with a NAT Gateway
- and, allow these private subnets outbound egress to Internet through existing Internet Gateway

## Apply

```
terraform init
terraform plan
terraform apply
...
...
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

default_availability_zones = [
    ap-southeast-2a,
    ap-southeast-2b,
    ap-southeast-2c
]
default_internet_gateway = igw-014899965f4751ca6
default_public_subnets = [
    subnet-08aaab4bf42ff54d4,
    subnet-01398b0687fc7502f,
    subnet-05608dd7105c12642
]
default_vpc_id = vpc-0f78dafae9a05f5fd
private_nat_gateway = nat-0fb8d6b77d5a5a2a8
private_nat_gateway_eip = 54.153.248.136
private_route_table = rtb-0e1cc22bbcbd08fe0
private_subnet_2a = subnet-0649200f9dd1f51b9
private_subnet_2b = subnet-0e80f80991e41262e
private_subnet_2c = subnet-0238c413f848661bc
```

## Usage

```
cd usage
terraform init
terraform plan
terraform apply
...
...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

private_subnets = [
    subnet-0e80f80991e41262e,
    subnet-0238c413f848661bc,
    subnet-0649200f9dd1f51b9
]
```
