variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
