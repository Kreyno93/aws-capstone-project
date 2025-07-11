# Migration Guide: From Old Structure to New Modular Structure

This guide helps you migrate from the old flat Terraform structure to the new modular, best-practices structure.

## 🔄 What Changed

### Old Structure (Flat Files)
```
├── provider.tf
├── var.tf
├── vpc.tf
├── public-subnet.tf
├── private-subnet.tf
├── igw.tf
├── nat.tf
├── routetable.tf
├── sg.tf
├── ec2.tf
├── alb.tf
├── autoscaling.tf
├── rds.tf
├── userdata.sh
└── bastion-userdata.sh
```

### New Structure (Modular)
```
├── terraform.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── data.tf
├── main.tf
├── outputs.tf
├── modules/
│   ├── networking/
│   ├── security/
│   ├── database/
│   └── compute/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── scripts/
```

## 📋 Migration Steps

### Step 1: Backup Current State

```bash
# Backup your current Terraform state
cp terraform.tfstate terraform.tfstate.backup
cp terraform.tfstate.backup terraform.tfstate.old

# Backup your current configuration
mkdir -p backup/old-structure
cp *.tf backup/old-structure/
cp *.sh backup/old-structure/
```

### Step 2: Understand Resource Mapping

| Old File | New Location | Notes |
|----------|--------------|-------|
| `provider.tf` | `terraform.tf` + `providers.tf` | Split into requirements and provider config |
| `var.tf` | `variables.tf` | Enhanced with better descriptions and validation |
| `vpc.tf` | `modules/networking/main.tf` | Part of networking module |
| `public-subnet.tf` | `modules/networking/main.tf` | Consolidated into networking |
| `private-subnet.tf` | `modules/networking/main.tf` | Consolidated into networking |
| `igw.tf` | `modules/networking/main.tf` | Consolidated into networking |
| `nat.tf` | `modules/networking/main.tf` | Consolidated into networking |
| `routetable.tf` | `modules/networking/main.tf` | Consolidated into networking |
| `sg.tf` | `modules/security/main.tf` | Dedicated security module |
| `ec2.tf` | `modules/compute/main.tf` | Part of compute module |
| `alb.tf` | `modules/compute/main.tf` | Part of compute module |
| `autoscaling.tf` | `modules/compute/main.tf` | Part of compute module |
| `rds.tf` | `modules/database/main.tf` | Dedicated database module |
| `userdata.sh` | `scripts/wordpress-userdata.sh` | Enhanced and moved to scripts |
| `bastion-userdata.sh` | `scripts/bastion-userdata.sh` | Enhanced and moved to scripts |

### Step 3: Migration Options

#### Option A: Fresh Deployment (Recommended for Development)

1. **Destroy old infrastructure** (if safe to do so):
   ```bash
   terraform destroy
   ```

2. **Initialize new structure**:
   ```bash
   terraform init
   ```

3. **Deploy with new structure**:
   ```bash
   ./scripts/deploy.sh dev apply
   ```

#### Option B: State Migration (For Production)

1. **Import existing resources** into new modules:
   ```bash
   # Example: Import VPC
   terraform import module.networking.aws_vpc.main vpc-xxxxxxxxx
   
   # Example: Import security groups
   terraform import module.security.aws_security_group.alb sg-xxxxxxxxx
   ```

2. **Verify state alignment**:
   ```bash
   terraform plan -var-file="environments/dev/terraform.tfvars"
   ```

3. **Apply any necessary changes**:
   ```bash
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

### Step 4: Update Variable Values

#### Old Variables → New Variables

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| `region_us_west_2` | `aws_region` | Simplified naming |
| `aws_availability_zone_a` | `availability_zones[0]` | Now a list |
| `aws_availability_zone_b` | `availability_zones[1]` | Now a list |
| `aws_instance_type_t2micro` | `instance_type` | Simplified naming |

#### Example Variable Migration

**Old `var.tf`:**
```hcl
variable "region_us_west_2" {
  type        = string
  description = "value for the region"
  default     = "us-west-2"
}
```

**New `variables.tf`:**
```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}
```

### Step 5: Update Deployment Process

#### Old Deployment
```bash
terraform init
terraform plan
terraform apply
```

#### New Deployment
```bash
# Using deployment script (recommended)
./scripts/deploy.sh dev plan
./scripts/deploy.sh dev apply

# Or traditional way with environment-specific vars
terraform init
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```

## 🔍 Key Differences

### 1. Resource Organization

**Old**: All resources in root files
**New**: Resources organized by function in modules

### 2. Variable Management

**Old**: Single `var.tf` file
**New**: Comprehensive variables with validation and environment-specific values

### 3. Environment Management

**Old**: No environment separation
**New**: Dedicated environment configurations

### 4. Security Improvements

**Old**: Basic security groups
**New**: Enhanced security with proper IAM roles and least privilege

### 5. Monitoring

**Old**: Basic health checks
**New**: Comprehensive monitoring with CloudWatch integration

### 6. Automation

**Old**: Manual deployment
**New**: Automated deployment and testing scripts

## ✅ Verification Steps

After migration, verify everything works:

1. **Check Terraform State**:
   ```bash
   terraform show
   ```

2. **Run Tests**:
   ```bash
   ./scripts/test-infrastructure.sh
   ```

3. **Verify Outputs**:
   ```bash
   terraform output
   ```

4. **Test WordPress Access**:
   ```bash
   curl -I $(terraform output -raw wordpress_url)
   ```

## 🚨 Rollback Plan

If migration fails, you can rollback:

1. **Restore old state**:
   ```bash
   cp terraform.tfstate.old terraform.tfstate
   ```

2. **Restore old configuration**:
   ```bash
   cp backup/old-structure/*.tf .
   cp backup/old-structure/*.sh .
   ```

3. **Reinitialize**:
   ```bash
   terraform init
   terraform plan
   ```

## 📝 Post-Migration Checklist

- [ ] All resources are properly managed by Terraform
- [ ] WordPress site is accessible
- [ ] Database connectivity works
- [ ] Auto Scaling Group is healthy
- [ ] Load balancer health checks pass
- [ ] Bastion host is accessible
- [ ] All tests pass
- [ ] Monitoring is working
- [ ] Backup old files are stored safely
- [ ] Team is trained on new deployment process

## 🎯 Benefits of New Structure

1. **Modularity**: Reusable components
2. **Maintainability**: Easier to update and manage
3. **Scalability**: Easy to add new environments
4. **Security**: Enhanced security practices
5. **Automation**: Deployment and testing scripts
6. **Documentation**: Better organized and documented
7. **Best Practices**: Following Terraform and AWS best practices

## 🆘 Troubleshooting Migration Issues

### Issue: Resource Already Exists
**Solution**: Use `terraform import` to import existing resources

### Issue: State Conflicts
**Solution**: Use `terraform state` commands to manage state

### Issue: Variable Not Found
**Solution**: Check variable name mapping in the table above

### Issue: Module Not Found
**Solution**: Run `terraform init` to download modules

### Issue: Permission Denied
**Solution**: Check AWS credentials and IAM permissions

## 📞 Getting Help

If you encounter issues during migration:

1. Check this migration guide
2. Review the troubleshooting section in README-NEW.md
3. Use `terraform plan` to see what changes will be made
4. Test in development environment first
5. Open an issue in the repository

---

**Remember**: Always test migrations in a development environment before applying to production!
