variable "prefix_projet" {
    description = " prefix for the project"
    default         = "epam-mentor-s-us1"
}

variable "keyName" {
  default  = "North-America-Virginia"
}

variable "ami" {
  default  =      "ami-0903e6ebabe59d793" #Custom image ldapserver
}
