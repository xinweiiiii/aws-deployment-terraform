variable "vpc_id" {
  description = "The CIDR block of the vpc"
}

variable "public_subnet" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnet" {
  type        = list
  description = "The CIDR block for the private subnet"
}