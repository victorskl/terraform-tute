# aws-iam

### Role
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_compare-resource-policies.html


### Policy
- https://docs.aws.amazon.com/IAM/latest/UserGuide/access.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
- https://aws.amazon.com/blogs/security/writing-iam-policies-how-to-grant-access-to-an-amazon-s3-bucket/
- https://aws.amazon.com/blogs/security/writing-iam-policies-grant-access-to-user-specific-folders-in-an-amazon-s3-bucket/


### Best Practices
- https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

---

The key idea of when to use/need AWS IAM is;

1. When one AWS service subscribe/consume to another AWS service. Example, EC2 instance need to use S3 bucket, then, you need a proper Role and Policy to allow this consumption.

2. When you want to consolidate multi-tier organizational deployments. This is the case that you will be deploying many tier-ed applications into different environments (dev, staging, prod, UAT, etc). AWS promotes by IAM account isolation for this purpose. Therefore, this is subjective to organizational practice and needs.

---

- https://gist.github.com/victorskl/46b8dc77df9bcaf00725f3263b20b844
- https://hackernoon.com/terraform-with-aws-assume-role-21567505ea98
- [Creating and attaching an AWS IAM role, with a policy to an EC2 instance using Terraform scripts
](https://medium.com/@kulasangar91/creating-and-attaching-an-aws-iam-role-with-a-policy-to-an-ec2-instance-using-terraform-scripts-aa85f3e6dfff)
- [AWS IAM User and Policy Creation using Terraform
](https://medium.com/devopslinks/aws-iam-user-and-policy-creation-using-terraform-7cd781e06c97)
