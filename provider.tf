# define AWS as provider
provider "aws" {
    region = "ap-southeast-1"
}

# Terraform remote state - Store in S3
terraform {
    backend "s3"{
        bucket = "is458-wms-terraform"
        key = "is458-wms-terraform/terraform.tfstate"
        region = "ap-southeast-1"
    }
}

