# AWS Deployment Using Terraform 

Sample terraform code for the following services
- ECS Fargate
- ECR
- Networking Layer
- WAF
- API Gateway
- DynamoDB
- Cloudwatch Event


## Run Deployment
Before running do ensure that you have your AWS Cli configured. [Instruction](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

`terraform init`

`terraform plan`

`terraform apply`

`terraform destroy`

## File Structure 
Each AWS Services should be created as a directory under modules, each services will include the folloing components `main.tf`, `output.tf` and `variable.tf`

## Best Practices
[Clean Terraform Code](https://medium.com/@ranjana-jha/infrastructure-as-a-code-best-practices-terraform-d7ae4291d621)

