variable "public_subnet_ids"{type = set(string)}
variable "public_sgr"{}
variable "azs" {}
variable "prefix_projet" {}
variable "tags" {}

variable "elb_internal" {
  default = "false"
}

variable "cross_zone_load_balancing" {
    default     = true
}

variable "idle_timeout" {
    default     = 60
}

variable "connection_draining" {
    default     = false
}

variable "connection_draining_timeout" {
    default     = 300
}

variable "instance_port" {
    default     = 80
}

variable "instance_protocol" {
    default     = "http"
}

variable "lb_port" {
    default     = 80
}

variable "lb_protocol" {
    default     = "http"
}

variable "healthy_threshold" {
    default     = 2
}

variable "unhealthy_threshold" {
    default     = 2
}

variable "timeout" {
    default     = 3
}

variable "target" {
    default     = "HTTP:80/"
}

variable "interval" {
    default     = 30
}

variable "listener" {
    description = "A list of Listener block"
    default     = []
}

#-----------------------------------------------------------
# ELB attachment
#-----------------------------------------------------------
variable "enable_elb_attachment" {
  description   = "Enable elb_attachment usage"
  default       = false
}

variable "instances" {
    description = " Instances ID to add them to ELB"
    default     = []
}

variable "elb_id" {
  description   = "ID of ELB"
  default       = ""
}

