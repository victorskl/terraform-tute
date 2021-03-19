# aws-ec2-instance

- [Amazon EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [Amazon Machine Images (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
    - [AMI Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ComponentsAMIs.html) -- [EBS-Backed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html) or [Instance Store-Backed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-instance-store.html)
- [Linux AMI Virtualization Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html)
    - HVM(hardware virtual machine) or PV(paravirtual)
- [Finding a Linux AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)
- [Amazon Linux](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-ami-basics.html)
    - **Old** [Amazon Linux AMI](https://aws.amazon.com/amazon-linux-ami/)
    - [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/) -- _use this!_
- [Launch from marketplace](https://aws.amazon.com/mp/linux/)
    - e.g. All available [CentOS versions](https://aws.amazon.com/marketplace/seller-profile?id=16cb8b03-256e-4dde-8f34-1b0f377efe89)
    - [Use Product Code from CentOS Wiki](https://wiki.centos.org/Cloud/AWS) to filter
- [Query for the latest Amazon Linux AMI IDs using AWS Systems Manager Parameter Store](https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/)

### Using CLI to determine AMI
- https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html

```
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2*" --query 'sort_by(Images, &CreationDate)[].Name'

aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-minimal*" --query 'sort_by(Images, &CreationDate)[].Name'

aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic*" --query 'sort_by(Images, &CreationDate)[].Name'

aws --region ap-southeast-2 ec2 describe-images --owners aws-marketplace --filters "Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce"
```

### Using terraform to determine AMI
```
cd ami-image
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy
```

### Using terraform to launch an instance
```
cd aws-ec2-instance
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy
```

### Connecting to EC2 instance
- It should be straight forward using SSH connect
```
ssh -i ~/.ssh/my_ec2_private_key.pem ec2-user@ec2-a-b-c-d.us-west-2.compute.amazonaws.com
```

Otherwise, read also:
- [General Prerequisites for Connecting to Your Instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connection-prereqs.html)
- [Set Up EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html)
- [Connect Using EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html)
- [Connecting to Your Linux Instance Using Session Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/session-manager.html)

### Multiple NICs

- https://www.terraform.io/docs/providers/aws/r/instance.html#network-interfaces
- https://www.terraform.io/docs/providers/aws/r/network_interface.html
- https://www.terraform.io/docs/providers/aws/r/network_interface_attachment.html
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/MultipleIP.html
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html

## Pricing

- [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html)
- [On-Demand Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html)
- From https://aws.amazon.com/ec2/pricing/

Spot
```
t3.nano   $0.004 per Hour $0.005 per Hour
t2.micro  $0.008 per Hour $0.01  per Hour

t3a.nano  $0.003 per Hour $0.004 per Hour
t3a.micro $0.007 per Hour $0.008 per Hour
```

On-demand
```
t3.nano   2 Variable  0.5 GiB EBS Only  $0.0066 per Hour
t3.micro  2 Variable  1 GiB   EBS Only  $0.0132 per Hour

t3a.nano  2 Variable  0.5 GiB EBS Only  $0.0059 per Hour
t3a.micro 2 Variable  1 GiB   EBS Only  $0.0119 per Hour

t2.nano   1 Variable  0.5 GiB EBS Only  $0.0073 per Hour
t2.micro  1 Variable  1 GiB   EBS Only  $0.0146 per Hour
```

## EBS

- https://aws.amazon.com/ebs/
- [What’s the difference between an AMI and EBS snapshots?](https://cloudranger.com/ami-or-ebs-snapshots/)
- [Where are my Amazon EBS snapshots stored?](https://cloudranger.com/amazon-ebs-snapshots-stored/)
