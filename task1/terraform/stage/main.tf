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
  source = "../modules/vpc"
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
  source = "../modules/bastion"
  public_subnet_ids = module.vpc.public_subnet_ids
  public_sgr    = module.vpc.public_sgr
  tags          = var.tags
  prefix_projet = var.prefix_projet
  keyName       = var.keyName 
  ami_bst       = var.ami_bst 
  azs           = var.azs
  asg_recurrence_scale_up   = var.asg_recurrence_scale_up
  asg_recurrence_scale_down = var.asg_recurrence_scale_down
  load_balancers = module.elb.elb_id
}
 

module "ldapser" {
  source = "../modules/ldapser"
  private_subnet_id = module.vpc.private_subnet_id
  private_sgr   = module.vpc.private_sgr
  tags          = var.tags
  prefix_projet = var.prefix_projet
  keyName       = var.keyName 
  ami_ldap      = var.ami_ldap
  azs           = var.azs
  ldap_privat_ip = var.ldap_privat_ip
}

module "elb" {
  source = "../modules/elb"
  public_subnet_ids = module.vpc.public_subnet_ids
  public_sgr    = module.vpc.public_sgr
  tags          = var.tags
  prefix_projet = var.prefix_projet
  azs           = var.azs
  instance_port     = var.instance_port
  instance_protocol = var.instance_protocol
  lb_port           = var.lb_port 
  lb_protocol       = var.lb_protocol
  target            = var.target
  listener = [
        {
            instance_port     = 80
            instance_protocol = "http"
            lb_port           = 80
            lb_protocol       = "http"
        },
        {
            instance_port      = 22
            instance_protocol  = "tcp"
            lb_port            = 22
            lb_protocol        = "tcp"
        }
    ]
}