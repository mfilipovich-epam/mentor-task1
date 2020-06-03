resource "aws_instance" "ldapser" {
    ami = var.ami_ldap
    availability_zone = "us-east-1b"
    instance_type = "t2.micro"
    key_name = var.keyName
    vpc_security_group_ids = ["${var.private_sgr}"]
    subnet_id = var.private_subnet_id
    private_ip = "10.0.40.100"
    source_dest_check = false

    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-ldp"), "Role", "ldapserver")
    )

    lifecycle {
      create_before_destroy = true
    }
}