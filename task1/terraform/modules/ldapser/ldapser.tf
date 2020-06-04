resource "aws_instance" "ldapser" {
    ami = var.ami_ldap
    availability_zone = var.azs[1]
    instance_type = var.inst_type
    key_name = var.keyName
    vpc_security_group_ids = ["${var.private_sgr}"]
    subnet_id = var.private_subnet_id
    private_ip = var.ldap_privat_ip
    source_dest_check = false

    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-ldp"), "Role", "ldapserver")
    )

    lifecycle {
      create_before_destroy = true
    }
}