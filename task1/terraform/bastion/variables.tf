variable "azs" {
    default = [
         "us-east-1a",
         "us-east-1b",
         "us-east-1c"
    ]
}

variable "prefix_projet" {
    description = " prefix for the project"
    default         = "epam-mentor-s-us1"
}

variable "amis" {
  type = map
  default = {
    "us-east-1" = "ami-098f16afa9edf40be" #Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
  }
}

variable "keyName" {
  default  = "North-America-Virginia"
}

variable "ami" {
  default  =      "ami-01ccdaaac167cb80a" #Custom image bastion with SSSD
}
