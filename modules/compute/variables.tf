variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "wordpress_security_group_id" {
  description = "Security group ID for WordPress instances"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group ID for Bastion host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_instance_type" {
  description = "Bastion host instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the key pair"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 50
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy threshold"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
  default     = 2
}

variable "db_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
