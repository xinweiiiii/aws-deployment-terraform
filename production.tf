module "networking" {

source = "./modules/networking"
  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${var.production_availability_zones}"
}

module "fargate" {
    
    source = "./modules/fargate"
    vpc_id = module.networking.vpc_id
    private_subnet = module.networking.private_subnet
    public_subnet = module.networking.public_subnet
}

module "dynamo" {
    source = "./modules/dynamo"
}

module "cloudwatch-event" {
    source = "./modules/cloudwatch-event"
}

module "waf" {
    source = "./modules/waf"
    ALB = module.fargate.ALB
}