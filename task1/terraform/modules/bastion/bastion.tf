resource "aws_launch_configuration" "bastion" {
    name_prefix                 = "${var.prefix_projet}-lac-bst"
    image_id                    = var.ami_bst
    instance_type               = var.inst_type
    key_name                    = var.keyName
    security_groups             = ["${var.public_sgr}"]
    associate_public_ip_address = true
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "bastion-asg" {
    name                      = "${var.prefix_projet}-bst"
    vpc_zone_identifier       = var.public_subnet_ids
    max_size                  = var.asg_max_size
    min_size                  = var.asg_min_size
    health_check_grace_period = var.health_check_grace_period
    default_cooldown          = var.default_cooldown
    health_check_type         = var.health_check_type
    desired_capacity          = var.desired_capacity
    suspended_processes       = var.suspended_processes
    force_delete              = true
    launch_configuration      = aws_launch_configuration.bastion.name
    tags = [
    {
      key                 = "Owner"
      value               = "mfilipovich"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.prefix_projet}-bst"
      propagate_at_launch = true
    },
    {
      key                 = "Role"
      value               = "bastion"
      propagate_at_launch = true
    }
    ]
    lifecycle {
      create_before_destroy = true
    }
    depends_on             = [aws_launch_configuration.bastion]
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {

    scheduled_action_name   = "scale-out-during-business-hours"
    min_size                = var.asg_min_size
    max_size                = var.asg_max_size
    desired_capacity        = var.desired_capacity
    recurrence              = var.asg_recurrence_scale_up
    autoscaling_group_name  = aws_autoscaling_group.bastion-asg.name
    depends_on              = [aws_autoscaling_group.bastion-asg]
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {

    scheduled_action_name   = "scale-in-at-night"
    min_size                = var.asg_night_size_min
    max_size                = var.asg_night_size_max
    desired_capacity        = var.asg_night_desired
    recurrence              = var.asg_recurrence_scale_down
    autoscaling_group_name  = aws_autoscaling_group.bastion-asg.name
#    start_time             = "2020-06-04T19:00:00Z"
#    end_time               = "2020-12-12T06:00:00Z"

    depends_on              = [aws_autoscaling_group.bastion-asg]
}
