provider "aws" {
  region = var.region
}
#terraform {
#  backend "s3" {
#    bucket = "epam-mentor-s-bck-us1"
#    key    = "aws-terraform-tfstate"
#    region = "us-east-1"
#  }
#}

module "vpc" {
  source = "./vpc"

}

#    module "networking" {
#    source = "./network"
#    }

module "bastion" {
  source = "./bastion"
  public_subnet_ids = module.vpc.public_subnet_ids
  public_sgr = module.vpc.public_sgr
}
 

module "ldapser" {
  source = "./ldapser"
  private_subnet_id = module.vpc.private_subnet_id
  private_sgr = module.vpc.private_sgr
}

