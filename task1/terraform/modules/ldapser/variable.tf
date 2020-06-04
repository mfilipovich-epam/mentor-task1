variable "prefix_projet" {}

variable "keyName" {}
variable "azs" {}
variable "ami_ldap" {}
variable "private_subnet_id"{}
variable "private_sgr"{}

variable  "tags" {}

variable  "ldap_privat_ip" {}

variable "inst_type"{
    default = "t2.micro"
}