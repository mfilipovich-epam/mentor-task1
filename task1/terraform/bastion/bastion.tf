variable "public_subnet_ids"{type = set(string)}
variable "public_sgr"{}


resource "aws_autoscaling_group" "bastion-asg" {
    name                      = "${var.prefix_projet}-bst"
    vpc_zone_identifier       = var.public_subnet_ids
    max_size                  = 1
    min_size                  = 1
    health_check_grace_period = 60
    default_cooldown          = 60
    health_check_type         = "EC2"
    desired_capacity          = 1
    force_delete              = true
    launch_configuration      = aws_launch_configuration.bastion.name
    tag {
      key                 = "Name"
      value               = "${var.prefix_projet}-bst"
      propagate_at_launch = true
    }
    tag {
      key                 = "Role"
      value               = "bastion"
      propagate_at_launch = true
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_launch_configuration" "bastion" {
    name_prefix                 = "${var.prefix_projet}-lac-bst"
    image_id                    =  var.ami
    instance_type               = "t2.micro"
    key_name                    = var.keyName
    security_groups             = ["${var.public_sgr}"]
    associate_public_ip_address = true
    lifecycle {
      create_before_destroy = true
    }
}

