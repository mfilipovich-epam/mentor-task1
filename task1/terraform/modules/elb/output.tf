output "elb_id" {
  description = "The name of the ELB"
  value       = element(concat(aws_elb.elb-bst.*.id, [""]), 0)
}

output "elb_name" {
  description = "The name of the ELB"
  value       = element(concat(aws_elb.elb-bst.*.name, [""]), 0)
}

output "elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = element(concat(aws_elb.elb-bst.*.dns_name, [""]), 0)
}

output "elb_instances" {
  description = "The list of instances in the ELB"
  value       = element(concat(aws_elb.elb-bst.*.instances, [""]), 0)
}