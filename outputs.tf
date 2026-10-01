# Output values for the AWS Capstone WordPress Infrastructure

# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.networking.nat_gateway_ip
}

# Load Balancer Outputs
output "wordpress_url" {
  description = "URL to access WordPress site"
  value       = "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.compute.alb_zone_id
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "database_name" {
  description = "Name of the WordPress database"
  value       = module.database.db_name
}

# Compute Outputs
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.compute.bastion_public_ip
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.autoscaling_group_name
}

# Security Group IDs
output "security_group_ids" {
  description = "Security group IDs"
  value = {
    alb       = module.security.alb_security_group_id
    wordpress = module.security.wordpress_security_group_id
    bastion   = module.security.bastion_security_group_id
    rds       = module.security.rds_security_group_id
  }
}

# Connection Information
output "ssh_connection_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${module.compute.bastion_public_ip}"
}

output "database_connection_info" {
  description = "Database connection information"
  value = {
    endpoint = module.database.db_instance_endpoint
    port     = module.database.db_instance_port
    database = module.database.db_name
    username = module.database.db_username
  }
  sensitive = true
}

# Resource Summary
output "resource_summary" {
  description = "Summary of created resources"
  value = {
    vpc_cidr            = module.networking.vpc_cidr_block
    availability_zones  = var.availability_zones
    public_subnets      = length(module.networking.public_subnet_ids)
    private_subnets     = length(module.networking.private_subnet_ids)
    wordpress_instances = "${var.min_size}-${var.max_size} (desired: ${var.desired_capacity})"
    database_instance   = var.db_instance_class
    bastion_instance    = var.bastion_instance_type
    load_balancer       = "Application Load Balancer"
  }
}

# Quick Start Information
output "quick_start_info" {
  description = "Quick start information for accessing the infrastructure"
  value = {
    wordpress_site = "http://${module.compute.alb_dns_name}"
    bastion_ssh    = "ssh -i ${var.key_pair_name}.pem ec2-user@${module.compute.bastion_public_ip}"
    health_check   = "http://${module.compute.alb_dns_name}/health.php"
    setup_complete = "Wait 5-10 minutes for WordPress installation to complete"
    dashboard_url  = module.monitoring.dashboard_url
  }
}

# Monitoring Information
output "monitoring_info" {
  description = "Monitoring and logging information"
  value = {
    dashboard_url = module.monitoring.dashboard_url
    log_groups    = module.monitoring.log_group_names
  }
}
