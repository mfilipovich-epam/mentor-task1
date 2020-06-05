tags = {
    Owner = "mfilipovich"
}

region        = "us-east-1"
prefix_projet = "epam-mentor-s-us1"
keyName       = "North-America-Virginia"

ami_ldap      = "ami-0a5755317fd57a61a" #Custom image ldapserver

ami_bst       = "ami-04b782afe74d4ab52" #Custom image bastion with SSSD

ami_nat       = "ami-00a9d4a05375b2763" # Amazon nat image

vpc_cidr      =  "10.0.0.0/16"

azs  =  [ "us-east-1a", "us-east-1b", "us-east-1c" ]

cidr_block_private  =  [ "10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19" ]

cidr_block_public  =  [ "10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20" ]

ldap_privat_ip = "10.0.40.100"

access_list  =  [
    "178.125.228.216/32",
    "178.127.70.54/32",
    "37.215.180.247/32",
    "37.215.189.252/32",
    "37.215.164.236/32",
    "178.127.64.94/32"
    ]

asg_recurrence_scale_up = "30 06 * * *" # +3 utc

asg_recurrence_scale_down = "00 19 * * *" # +3 utc