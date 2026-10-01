# Production Environment Configuration

# Project Configuration
project_name = "aws-capstone-wordpress"
environment  = "prod"
owner        = "DevOps Team"

# AWS Configuration
aws_region         = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b"]

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]

# EC2 Configuration
instance_type         = "t3.small"
bastion_instance_type = "t3.micro"
key_pair_name         = "vockey"

# Auto Scaling Configuration
min_size               = 2
max_size               = 6
desired_capacity       = 3
target_cpu_utilization = 70

# Database Configuration
db_instance_class          = "db.t3.small"
db_allocated_storage       = 100
db_engine_version          = "8.0.35"
db_name                    = "wordpress"
db_username                = "wordpressuser"
db_backup_retention_period = 30
db_backup_window           = "03:00-04:00"
db_maintenance_window      = "sun:04:00-sun:05:00"

# Load Balancer Configuration
health_check_path     = "/"
health_check_interval = 30
health_check_timeout  = 5
healthy_threshold     = 3
unhealthy_threshold   = 3

# Security Configuration - Restrict to specific IP ranges in production
allowed_cidr_blocks     = ["0.0.0.0/0"] # Update with specific IP ranges
ssh_allowed_cidr_blocks = ["0.0.0.0/0"] # Update with admin IP ranges

# Monitoring Configuration
enable_detailed_monitoring = true
log_retention_days         = 90
