variable "private_subnet_id"{}
variable "private_sgr"{}

resource "aws_instance" "ldapser" {
    ami = var.ami
    availability_zone = "us-east-1b"
    instance_type = "t2.micro"
    key_name = var.keyName
    vpc_security_group_ids = ["${var.private_sgr}"]
    subnet_id = var.private_subnet_id
    private_ip = "10.0.40.100"
    source_dest_check = false


    tags = {
        Owner       = "mfilipovich"
        Name        = "${var.prefix_projet}-ldp"
        Role        = "ldapserver"
    }

    lifecycle {
      create_before_destroy = true
    }
}