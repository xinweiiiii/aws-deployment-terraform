variable "region" {
  description = "ap-southeast-1"
}

variable "environment" {
  description = "is458-wms"
}

# Networking
variable "vpc_cidr" {
    description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
    type        = list
    description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
    type        = list
    description = "The CIDR block for the private subnet"
}

variable "production_availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}
