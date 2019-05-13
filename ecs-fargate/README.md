# aws-ecs-fargate

AWS ECS Fargate tutorials

### what is required to run app in ECS Fargate?

0. [Setting Up with Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html)
1. IAM Roles and Policy
    - If Fargate launch type (+ECR,+SecretManager,+ParameterStore), typically `ecsTaskExecutionRole` is required.
        - [Amazon ECS Task Execution IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html)
    - If using ALB, `ecsServiceRole` is required.
        - [Amazon ECS Service Scheduler IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_IAM_role.html)
        - [Check the Service Role for Your Account](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/check-service-role.html)
    - If using Auto Scaling, `ecsAutoscaleRole` is required.
        - [Amazon ECS Service Auto Scaling IAM Role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/autoscale_IAM_role.html)
    - More details and inter-services permission requirement, refer [Amazon ECS IAM Policies, Roles, and Permissions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/IAM_policies.html)
2. Normally, ECS Fargate launch type requires ALB to front services (i.e. app or docker containers; just like HAProxy to front docker-compose services in a classic instance-backed analogy)
    - [Service Load Balancing](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html)
    - [Load Balancer Types](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/load-balancer-types.html)
    - [What Is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
3. A task definition is required to run Docker containers in Amazon ECS.
    - [Amazon ECS Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
    - [Creating a Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html)
    - [Task Definition Parameters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html)
4. Container Volume
    - [Using Data Volumes in Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html)
    - [Fargate Task Storage](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-storage.html)
    - [Bind Mounts](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/bind-mounts.html)
5. Can use either default VPC or create a new VPC
    - [Default VPC and Default Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html)
    - [Tutorial: Creating a VPC with Public and Private Subnets for Your Clusters](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-public-private-vpc.html)
    - [VPCs and Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
    - [Scenarios and Examples](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenarios.html)
6. Create any necessary Security Group to allow/deny filter the information flow: `Internet--ingress-->ALB-->ingress--> ECS`
7. Create `CloudWatch` log group for `awslog` driver



### write-your-own-ecs-module
_By nature, containerisation is unique to application specific. It is norm that terraform-ing ECS is context-aware and, opinionated to how application is being containerised to run. Therefore, it ends up [WET principal](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) i.e. write-your-own-ecs-module approach better fit the bill; instead of re-using someone else "ecs" module!_

- https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
- https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
- https://www.terraform.io/docs/providers/aws/r/ecs_service.html


---

### ECS with ALB example

- https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/ecs-alb
- (EC2 launch type; terraform aws provider very own example)

### terraform-aws-ecs

- https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/1.3.0
- https://github.com/terraform-aws-modules/terraform-aws-ecs
- (EC2 launch type; incomplete)

### Setting up ECS with Terraform

- https://blog.ulysse.io/post/setting-up-ecs-with-terraform/
- (EC2 launch type)

### terraform_ecs_fargate_example

Tute from:

- [Easy deploy your Docker applications to AWS using ECS and Fargate](https://thecode.pub/easy-deploy-your-docker-applications-to-aws-using-ecs-and-fargate-a988a1cc842f)
- https://github.com/duduribeiro/terraform_ecs_fargate_example

### terraform-ecs-fargate

Tute from:

- [Deploying Containers on Amazon’s ECS using Fargate and Terraform: Part 1](https://medium.com/@bradford_hamilton/deploying-containers-on-amazons-ecs-using-fargate-and-terraform-part-1-a5ab1f79cb21)
- [Deploying Containers on Amazon’s ECS using Fargate and Terraform: Part 2](https://medium.com/@bradford_hamilton/deploying-containers-on-amazons-ecs-using-fargate-and-terraform-part-2-2e6f6a3a957f)
- https://github.com/bradford-hamilton/terraform-ecs-fargate


Files in-order:

1. provider.tf
2. variables.tf
3. network.tf
4. security.tf
5. alb.tf
6. ecs.tf
7. auto_scaling.tf
8. logs.tf
9. outputs.tf


Clean-up:

- As per: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CleaningUp.html

    ```
    aws ecs list-clusters
    
    aws ecs list-services --cluster crystal-blockchain-cluster
    aws ecs update-service --cluster crystal-blockchain-cluster --service crystal-blockchain-container-service --desired-count 0 --region ap-southeast-2
    aws ecs delete-service --cluster crystal-blockchain-cluster --service crystal-blockchain-container-service --region ap-southeast-2
    
    aws ecs list-container-instances --cluster crystal-blockchain-cluster
    aws ecs deregister-container-instance --cluster crystal-blockchain-cluster --container-instance [container_instance_id] --region ap-southeast-2 --force
    
    aws ecs delete-cluster --cluster crystal-blockchain-cluster --region ap-southeast-2
    ```

- Then; delete CloudFormation stack

App:

- https://hub.docker.com/r/bradfordhamilton/crystal_blockchain
- https://github.com/bradford-hamilton/crystal-blockchain
```
docker run -p 3000:3000 -it --rm --name cbapp bradfordhamilton/crystal_blockchain
```

### provision-ecs-cluster-terraform

- [Setup a Container Cluster on AWS with Terraform Part 1-Provision a VPC](http://blog.shippable.com/create-a-container-cluster-using-terraform-with-aws-part-1)
- [Setup a Container Cluster on AWS with Terraform Part 2-Provision a CLUSTER](http://blog.shippable.com/setup-a-container-cluster-on-aws-with-terraform-part-2-provision-a-cluster)
- https://github.com/devops-recipes/provision-ecs-cluster-terraform

### anrim-terraform-aws-ecs

- https://github.com/anrim/terraform-aws-ecs

### terraform-ecs

- https://github.com/arminc/terraform-ecs

### terraform-amazon-ecs

- https://github.com/Capgemini/terraform-amazon-ecs

### ecs-terraform

- https://github.com/alex/ecs-terraform

---

```
git submodule update --init --recursive
```
