# aws-ecs-fargate

AWS ECS Fargate tutorials

## terraform-aws-ecs

Terraform AWS modules:

- https://registry.terraform.io/modules/terraform-aws-modules
- https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/1.3.0
- https://github.com/terraform-aws-modules/terraform-aws-ecs


## terraform_ecs_fargate_example

Tute from:

- [Easy deploy your Docker applications to AWS using ECS and Fargate](https://thecode.pub/easy-deploy-your-docker-applications-to-aws-using-ecs-and-fargate-a988a1cc842f)
- https://github.com/duduribeiro/terraform_ecs_fargate_example


## terraform-ecs-fargate

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

---

## anrim-terraform-aws-ecs

- https://github.com/anrim/terraform-aws-ecs


## terraform-ecs

- https://github.com/arminc/terraform-ecs


## terraform-amazon-ecs

- https://github.com/Capgemini/terraform-amazon-ecs


## ecs-terraform

- https://github.com/alex/ecs-terraform


