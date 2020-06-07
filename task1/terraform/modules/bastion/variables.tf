variable "public_subnet_ids"{type = set(string)}
variable "public_sgr"{}

variable "azs" {}

variable "prefix_projet" {}

variable "keyName" {}

variable "ami_bst" {}

variable "tags" {}

variable "inst_type"{
    default = "t2.micro"
}

variable "health_check_grace_period" {
    default = 60 
} 

variable "default_cooldown"{
    default = 60
}          

variable "health_check_type" {
    default     = "ELB"
}

variable "asg_max_size" {
    default     = 1
}

variable "asg_min_size" {
    default     = 1
}

variable "asg_size_scale" {
    default     = 1
}

variable "desired_capacity" {
    default     = 1
}

variable "asg_night_size_min" {
    default     = 0
}

variable "asg_night_size_max" {
    default     = 0
}

variable "asg_night_desired" {
    default     = 0
}

variable "asg_recurrence_scale_up" {
    default     = "30 06 * * *" # +3 utc
}

variable "asg_recurrence_scale_down" {
    default     = "00 19 * * *" # +3 utc
}

variable "suspended_processes" {
    type = list
    default     = []
}
