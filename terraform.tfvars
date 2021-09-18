region = "ap-southeast-1"
environment = "is458-wms"

vpc_cidr = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"] 
private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
production_availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]