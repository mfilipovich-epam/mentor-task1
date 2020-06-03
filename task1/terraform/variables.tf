variable "region" {
  default  = "us-east-1"
}
variable "inst_type" {
  default  = "t2.micro"
}

variable "keyName" {
  type = map
  default ={
    "us-east-1" = "North-America-Virginia"
  } 
}

variable "owner" {
       default = "mfilipovich"
}