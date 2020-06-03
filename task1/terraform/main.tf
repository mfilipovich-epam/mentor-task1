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
  region        = var.region
  tags          = var.tags
  prefix_projet = var.prefix_projet
  keyName       = var.keyName 
  ami_nat       = var.ami_nat
  vpc_cidr      = var.vpc_cidr
  azs           = var.azs
  cidr_block_private = var.cidr_block_private
  cidr_block_public = var.cidr_block_public
  access_list = var.access_list
}

module "bastion" {
  source = "./bastion"
  public_subnet_ids = module.vpc.public_subnet_ids
  public_sgr    = module.vpc.public_sgr
  tags          = var.tags
  prefix_projet = var.prefix_projet
  keyName       = var.keyName 
  ami_bst       = var.ami_bst 
  azs           = var.azs 
}
 

module "ldapser" {
  source = "./ldapser"
  private_subnet_id = module.vpc.private_subnet_id
  private_sgr   = module.vpc.private_sgr
  tags          = var.tags
  prefix_projet = var.prefix_projet
  keyName       = var.keyName 
  ami_ldap      = var.ami_ldap 
}

