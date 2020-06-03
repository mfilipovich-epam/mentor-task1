resource "aws_vpc" "mentor-vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy     = "default"
    enable_dns_support   = true
    enable_dns_hostnames = false
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-vpc"))
    )
}

resource "aws_internet_gateway" "mentor-igw" {
    vpc_id = aws_vpc.mentor-vpc.id
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-igw"))
    )
}

resource "aws_subnet" "public-subnets" {
    count             = length(var.azs)
    vpc_id            = aws_vpc.mentor-vpc.id
    cidr_block        = element(var.cidr_block_public, count.index)
    availability_zone = element(var.azs, count.index)
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-snt-pu${count.index}"))
    )
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnets" {
    count             = length(var.azs)
    vpc_id            = aws_vpc.mentor-vpc.id
    cidr_block        = element(var.cidr_block_private, count.index)
    availability_zone = element(var.azs, count.index)
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-snt-pr${count.index}"))
    )
}

resource "aws_route_table" "public-route" {
    vpc_id            = aws_vpc.mentor-vpc.id 
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mentor-igw.id
    }
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-rou-pub"))
    )
}

resource "aws_route_table_association" "public-route" {
    count          = length(var.cidr_block_public)
    subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
    route_table_id = aws_route_table.public-route.id
}

resource "aws_security_group" "public-sgr" {
    name = "${var.prefix_projet}-sgr-pub"
    description = "Public SGR for access"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = var.access_list
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = var.access_list
    }

    ingress {
        from_port = 389
        to_port = 389
        protocol = "tcp"
        cidr_blocks = var.cidr_block_private
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.access_list
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.mentor-vpc.id

    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-sgr-pub"))
    )
}


resource "aws_security_group" "nat-sgr" {
    name = "${var.prefix_projet}-sgr-nat"
    description = "Public SGR for access"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = var.cidr_block_private
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = var.cidr_block_private
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    ingress {
        from_port = 21
        to_port = 21
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 37000
        to_port = 64000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port = 21
        to_port = 21
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port = 37000
        to_port = 64000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.mentor-vpc.id

    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-sgr-nat"))
    )
}


resource "aws_instance" "mentor-natinst" {
    ami           = var.ami_nat
    availability_zone = var.azs[0]
    instance_type = "t2.micro"
    key_name = var.keyName
    vpc_security_group_ids = ["${aws_security_group.nat-sgr.id}"]
    subnet_id = aws_subnet.public-subnets[0].id
    associate_public_ip_address = true
    source_dest_check = false

    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-nat"), "Role", "natinst")
    )
}

resource "aws_route_table" "private-route" {
    vpc_id            = aws_vpc.mentor-vpc.id 
    route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.mentor-natinst.id
    }
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-rou-pri"))
    )
}

resource "aws_route_table_association" "private-route" {
    count          = length(var.cidr_block_public)
    subnet_id      = element(aws_subnet.private-subnets.*.id, count.index)
    route_table_id = aws_route_table.private-route.id
}

resource "aws_security_group" "private-sgr" {
    name = "${var.prefix_projet}-sgr-pri"
    description = "Public SGR for access"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
        

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.mentor-vpc.id

    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-sgr-pri"))
    )
}
