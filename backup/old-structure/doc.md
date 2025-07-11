# AWS Capstone Project Documentation

## Project Overview
This AWS Capstone Project implements a highly available, scalable WordPress hosting infrastructure using Terraform Infrastructure as Code (IaC). The architecture follows AWS best practices for security, scalability, and high availability.

## Architecture Components

### 1. Network Infrastructure
- **VPC**: Custom Virtual Private Cloud with CIDR block `10.0.0.0/16`
- **Availability Zones**: Multi-AZ deployment across `us-west-2a` and `us-west-2b`
- **Subnets**:
  - Public Subnet 1: `10.0.1.0/24` (us-west-2a)
  - Public Subnet 2: `10.0.3.0/24` (us-west-2b)
  - Private Subnet 1: `10.0.2.0/24` (us-west-2a)
  - Private Subnet 2: `10.0.4.0/24` (us-west-2b)

### 2. Internet Connectivity
- **Internet Gateway**: Provides internet access to public subnets
- **NAT Gateway**: Enables outbound internet access for private subnets
- **Elastic IP**: Associated with NAT Gateway for consistent public IP

### 3. Routing
- **Public Route Table**: Routes traffic from public subnets to Internet Gateway
- **Private Route Table**: Routes traffic from private subnets to NAT Gateway
- **Route Table Associations**: Properly associates subnets with their respective route tables

### 4. Security Groups
- **SSH Security Group**: Allows SSH access (port 22) from anywhere
- **Web Server Security Group**: Allows HTTP traffic (port 80) from anywhere
- **Load Balancer Security Group**: Allows HTTP traffic (port 80) for ALB
- **RDS Security Group**: Allows MySQL traffic (port 3306) for database access

### 5. Compute Infrastructure
- **Bastion Host**: EC2 instance in public subnet for secure access to private resources
- **Auto Scaling Group**: Manages WordPress instances in private subnets
- **Launch Template**: Defines configuration for auto-scaled instances

### 6. Load Balancing
- **Application Load Balancer (ALB)**: Distributes traffic across multiple WordPress instances
- **Target Group**: Health checks and routes traffic to healthy instances
- **Listener**: Handles incoming HTTP requests on port 80

### 7. Database
- **RDS MySQL Instance**: Managed database service for WordPress
- **Database Specifications**:
  - Engine: MySQL 8.0.35
  - Instance Class: db.t3.micro
  - Storage: 10GB
  - Multi-AZ: Disabled (for cost optimization)
- **DB Subnet Group**: Spans private subnets for high availability

### 8. Auto Scaling Configuration
- **Desired Capacity**: 2 instances
- **Minimum Size**: 2 instances
- **Maximum Size**: 3 instances
- **Scaling Policy**: Target tracking based on CPU utilization (50% threshold)
- **Cooldown Period**: 30 seconds

## Security Features

### Network Security
- WordPress instances deployed in private subnets (no direct internet access)
- Bastion host for secure administrative access
- NAT Gateway for outbound internet connectivity from private subnets

### Access Control
- Security groups implement principle of least privilege
- SSH access controlled through bastion host
- Database access restricted to application tier

### Data Protection
- RDS instance deployed in private subnets
- Database credentials managed through Terraform variables
- Skip final snapshot enabled for development environment

## Deployment Configuration

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed (version ~> 5.70.0)
- Key pair "vockey" available in us-west-2 region

### Variables
- **Region**: us-west-2
- **Instance Type**: t2.micro (cost-optimized)
- **Availability Zones**: us-west-2a, us-west-2b

### User Data Scripts
- **WordPress Instances**: Automated installation of Apache, PHP, MySQL client, and WordPress
- **Bastion Host**: Basic system updates and MySQL client installation
- **Database Configuration**: Automatic WordPress configuration with RDS endpoint

## High Availability Features

### Multi-AZ Deployment
- Resources distributed across two availability zones
- Load balancer spans multiple AZs
- Auto Scaling Group deploys instances across AZs

### Fault Tolerance
- Auto Scaling Group maintains desired instance count
- Health checks ensure traffic only routes to healthy instances
- RDS provides managed database with automated backups

### Scalability
- Horizontal scaling through Auto Scaling Group
- Target tracking scaling policy based on CPU utilization
- Load balancer automatically distributes traffic

## Monitoring and Health Checks

### Application Load Balancer Health Checks
- **Path**: `/` (root path)
- **Protocol**: HTTP
- **Port**: 80
- **Healthy Threshold**: 2 consecutive successful checks
- **Unhealthy Threshold**: 2 consecutive failed checks
- **Interval**: 60 seconds
- **Timeout**: 5 seconds

### Auto Scaling Monitoring
- CloudWatch metrics for CPU utilization
- Automatic scaling based on performance thresholds
- Instance warmup period: 30 seconds

## Cost Optimization

### Instance Sizing
- t2.micro instances for cost-effective compute
- db.t3.micro for RDS to minimize database costs
- Single NAT Gateway to reduce NAT charges

### Storage Optimization
- 10GB allocated storage for RDS
- No encryption to avoid additional charges (development environment)
- Skip final snapshot to avoid snapshot storage costs

## Deployment Instructions

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan Deployment**:
   ```bash
   terraform plan
   ```

3. **Apply Configuration**:
   ```bash
   terraform apply
   ```

4. **Access Application**:
   - Use the ALB DNS name to access WordPress
   - SSH to bastion host for administrative access

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Files Structure

- `provider.tf` - AWS provider configuration
- `var.tf` - Variable definitions
- `vpc.tf` - VPC configuration
- `public-subnet.tf` - Public subnet definitions
- `private-subnet.tf` - Private subnet definitions
- `igw.tf` - Internet Gateway configuration
- `nat.tf` - NAT Gateway and Elastic IP
- `routetable.tf` - Route tables and associations
- `sg.tf` - Security group definitions
- `ec2.tf` - EC2 instance configurations
- `alb.tf` - Application Load Balancer setup
- `autoscaling.tf` - Auto Scaling Group configuration
- `rds.tf` - RDS database setup
- `userdata.sh` - WordPress installation script
- `bastion-userdata.sh` - Bastion host setup script

## Best Practices Implemented

1. **Infrastructure as Code**: Complete infrastructure defined in Terraform
2. **Security**: Private subnets for application and database tiers
3. **High Availability**: Multi-AZ deployment with load balancing
4. **Scalability**: Auto Scaling Group with performance-based scaling
5. **Monitoring**: Health checks and CloudWatch integration
6. **Cost Optimization**: Right-sized instances and minimal resource allocation

## Future Enhancements

1. **SSL/TLS**: Add HTTPS support with ACM certificates
2. **CDN**: Implement CloudFront for content delivery
3. **Monitoring**: Enhanced monitoring with CloudWatch dashboards
4. **Backup**: Automated backup strategy for RDS and application data
5. **Security**: WAF implementation for additional security
6. **Multi-Region**: Cross-region deployment for disaster recovery
