variable "region" {
  default  = "us-east-1"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default         = "10.0.0.0/16"
}

variable "prefix_projet" {
    description = " prefix for the project"
    default         = "epam-mentor-s-us1"
}

variable "azs" {
    default = [
         "us-east-1a",
         "us-east-1b",
         "us-east-1c"
    ]
}

variable "cidr_block_private" {
    type= list
    default = [
    "10.0.0.0/19",
    "10.0.32.0/19",
    "10.0.64.0/19"
    ]
}

variable "cidr_block_public" {
    type= list
    default = [
    "10.0.128.0/20",
    "10.0.144.0/20",
    "10.0.160.0/20"
    ]
}

variable "access_list" {
    type= list
    default = [
    "178.125.228.216/32",
    "178.127.70.54/32",
    "37.215.180.247/32",
    "37.215.189.252/32"
    ]
}

variable "natamis" {
  type = map
  default = {
    "us-east-1" = "ami-00a9d4a05375b2763" # Amazon nat image
    "us-east-2" = "ami-0fc20dd1da406780b"
  }
}

variable "keyName" {
  type = map
  default ={
    "us-east-1" = "North-America-Virginia"
    "us-east-2" = "North-America-Ohio"
  } 
}

