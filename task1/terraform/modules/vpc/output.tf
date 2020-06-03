# vpc
output "vpc_id"                             { value = "${aws_vpc.mentor-vpc.id}" }
output "vpc_cidr"                           { value = "${var.vpc_cidr}" }

# subnets
output "public_subnet_ids"                  { value = aws_subnet.public-subnets.*.id }
output "private_subnet_ids"                 { value = aws_subnet.private-subnets.*.id }
output "private_subnet_id"                 { value = aws_subnet.private-subnets[1].id }

# security groups
output "public_sgr"       { value = "${aws_security_group.public-sgr.id}" }
output "private_sgr"       { value = "${aws_security_group.private-sgr.id}" }