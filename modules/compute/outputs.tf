output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.wordpress.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.wordpress.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.wordpress.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}
