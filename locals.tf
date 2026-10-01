locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }

  # Resource naming convention
  name_prefix = "${var.project_name}-${var.environment}"

  # Network configuration
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  # Database configuration
  db_port = 3306

  # Application configuration
  app_port = 80

  # Security group rules
  http_port  = 80
  https_port = 443
  ssh_port   = 22
}
