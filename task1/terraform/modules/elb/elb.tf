resource "aws_elb" "elb-bst" {
    name                        = "${var.prefix_projet}-elb-bst"
#    availability_zones          = var.azs
    subnets                     = var.public_subnet_ids
    security_groups             = ["${var.public_sgr}"]
    internal                    = var.elb_internal

    cross_zone_load_balancing   = var.cross_zone_load_balancing
    idle_timeout                = var.idle_timeout
    connection_draining         = var.connection_draining
    connection_draining_timeout = var.connection_draining_timeout

/*   listener {
        instance_port     = var.inatance_port
        instance_protocol = var.instance_protocol
        lb_port           = var.lb_port 
        lb_protocol       = var.lb_protocol 
    }
*/
    dynamic "listener" {
        for_each = var.listener
        content {
            instance_port       = lookup(listener.value, "instance_port", null)
            instance_protocol   = lookup(listener.value, "instance_protocol", null)
            lb_port             = lookup(listener.value, "lb_port", null)
            lb_protocol         = lookup(listener.value, "lb_protocol", null)
            ssl_certificate_id  = lookup(listener.value, "ssl_certificate_id", null)
        }
    }

    health_check {
        healthy_threshold   = var.healthy_threshold 
        unhealthy_threshold = var.unhealthy_threshold
        timeout             = var.timeout
        target              = var.target
        interval            = var.interval 
    }
    
    tags = merge(var.tags,
            map("Name", format("${var.prefix_projet}-elb-bst"))
    )

    lifecycle {
        create_before_destroy   = true
    }

    depends_on                  = []
}