# Main Terraform configuration for AWS Capstone WordPress Infrastructure

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  vpc_cidr             = local.vpc_cidr
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  availability_zones   = local.availability_zones
  tags                 = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  name_prefix             = local.name_prefix
  vpc_id                  = module.networking.vpc_id
  vpc_cidr                = module.networking.vpc_cidr_block
  allowed_cidr_blocks     = var.allowed_cidr_blocks
  ssh_allowed_cidr_blocks = var.ssh_allowed_cidr_blocks
  tags                    = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  name_prefix             = local.name_prefix
  subnet_ids              = module.networking.private_subnet_ids
  security_group_ids      = [module.security.rds_security_group_id]
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = random_password.db_password.result
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine_version          = var.db_engine_version
  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window
  multi_az                = false # Set to true for production
  skip_final_snapshot     = true  # Set to false for production
  tags                    = local.common_tags
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  name_prefix                 = local.name_prefix
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  private_subnet_ids          = module.networking.private_subnet_ids
  alb_security_group_id       = module.security.alb_security_group_id
  wordpress_security_group_id = module.security.wordpress_security_group_id
  bastion_security_group_id   = module.security.bastion_security_group_id
  instance_type               = var.instance_type
  bastion_instance_type       = var.bastion_instance_type
  key_pair_name               = var.key_pair_name
  min_size                    = var.min_size
  max_size                    = var.max_size
  desired_capacity            = var.desired_capacity
  target_cpu_utilization      = var.target_cpu_utilization
  health_check_path           = var.health_check_path
  health_check_interval       = var.health_check_interval
  health_check_timeout        = var.health_check_timeout
  healthy_threshold           = var.healthy_threshold
  unhealthy_threshold         = var.unhealthy_threshold
  db_endpoint                 = module.database.db_instance_endpoint
  db_name                     = module.database.db_name
  db_username                 = module.database.db_username
  db_password                 = module.database.db_password
  ami_id                      = data.aws_ami.amazon_linux.id
  enable_detailed_monitoring  = var.enable_detailed_monitoring
  tags                        = local.common_tags

  depends_on = [module.database]
}

# Monitoring Module (Optional)
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix            = local.name_prefix
  alb_arn                = module.compute.alb_arn
  autoscaling_group_name = module.compute.autoscaling_group_name
  rds_instance_id        = module.database.db_instance_id
  log_retention_days     = var.log_retention_days
  tags                   = local.common_tags

  depends_on = [module.compute, module.database]
}
