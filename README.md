# AWS Capstone Project - Scalable WordPress Infrastructure (Improved)

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-%23117AC9.svg?style=for-the-badge&logo=WordPress&logoColor=white)

## 🚀 Project Overview

This is an **improved and restructured** version of the AWS Capstone Project that demonstrates the implementation of a **highly available, scalable, and secure WordPress hosting infrastructure** using **Terraform Infrastructure as Code (IaC)** following modern best practices.

### 🎯 Key Improvements

- **Modular Architecture**: Organized into reusable Terraform modules
- **Environment Management**: Separate configurations for dev, staging, and prod
- **Enhanced Security**: Improved security groups and IAM roles
- **Better Monitoring**: CloudWatch integration and health checks
- **Automation Scripts**: Deployment and testing automation
- **Documentation**: Comprehensive documentation and examples
- **Best Practices**: Following Terraform and AWS best practices

### 🏗️ Architecture Components

The infrastructure consists of the following modules:

- **Networking Module**: VPC, subnets, gateways, and routing
- **Security Module**: Security groups and access control
- **Database Module**: RDS MySQL with proper configuration
- **Compute Module**: EC2 instances, Auto Scaling, and Load Balancer
- **Monitoring Module**: CloudWatch metrics and alarms (optional)

## 📁 Project Structure

```
aws-capstone-project/
├── README.md                    # This file
├── terraform.tf                 # Terraform version and provider requirements
├── providers.tf                 # Provider configurations
├── variables.tf                 # Variable definitions
├── locals.tf                    # Local values
├── data.tf                      # Data sources
├── main.tf                      # Main configuration using modules
├── outputs.tf                   # Output definitions
├── .gitignore                   # Git ignore rules
│
├── modules/                     # Terraform modules
│   ├── networking/              # VPC, subnets, gateways
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/                # Security groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── database/                # RDS configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                 # EC2, ASG, ALB
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/              # CloudWatch (optional)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/                # Environment-specific configurations
│   ├── dev/
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
│
└── scripts/                     # Utility scripts
    ├── deploy.sh                # Deployment automation
    ├── test-infrastructure.sh   # Infrastructure testing
    ├── wordpress-userdata.sh    # WordPress installation script
    └── bastion-userdata.sh      # Bastion host setup script
```

## 🚀 Quick Start Guide

### Prerequisites

- **AWS CLI** (v2.x or later) configured with appropriate credentials
- **Terraform** (v1.0 or later)
- **Git** for cloning the repository
- **Key Pair** named "vockey" in your AWS region (or update configuration)

### 1. Clone and Setup

```bash
git clone <your-repository-url>
cd aws-capstone-project
```

### 2. Deploy Infrastructure

Using the deployment script (recommended):

```bash
# Plan deployment for development environment
./scripts/deploy.sh dev plan

# Apply deployment for development environment
./scripts/deploy.sh dev apply

# Check outputs
./scripts/deploy.sh dev output
```

Or using Terraform directly:

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply deployment
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### 3. Test Infrastructure

```bash
# Run comprehensive infrastructure tests
./scripts/test-infrastructure.sh
```

### 4. Access WordPress

After deployment (5-10 minutes for complete setup):

1. Get the WordPress URL from Terraform outputs
2. Open the URL in your browser
3. Complete WordPress setup through the web interface

## 🔧 Configuration

### Environment Configuration

Each environment has its own configuration file in `environments/[env]/terraform.tfvars`:

- **dev**: Development environment with minimal resources
- **staging**: Staging environment for testing
- **prod**: Production environment with enhanced security and performance

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Name of the project | `aws-capstone-wordpress` |
| `environment` | Environment name | `dev` |
| `aws_region` | AWS region | `us-west-2` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `db_instance_class` | RDS instance class | `db.t3.micro` |
| `min_size` | Min ASG instances | `2` |
| `max_size` | Max ASG instances | `3` |

## 🛠️ Available Scripts

### Deployment Script

```bash
./scripts/deploy.sh [environment] [action]

# Examples:
./scripts/deploy.sh dev plan      # Plan dev deployment
./scripts/deploy.sh dev apply     # Apply dev deployment
./scripts/deploy.sh prod destroy  # Destroy prod environment
```

### Testing Script

```bash
./scripts/test-infrastructure.sh

# Tests include:
# - ALB health checks
# - WordPress response
# - Load balancing
# - Database connectivity
# - Auto Scaling Group health
```

## 🔒 Security Features

### Network Security
- Private subnets for application and database tiers
- Bastion host for secure administrative access
- Security groups with least privilege principles
- NAT Gateway for controlled outbound access

### Access Control
- IAM roles for EC2 instances
- Security group rules for specific ports and sources
- SSH key-based authentication
- Database access restricted to application tier

### Monitoring
- CloudWatch metrics and alarms
- Auto Scaling based on CPU utilization
- Health checks for load balancer targets
- Logging for troubleshooting

## 🧪 Testing

The project includes comprehensive testing:

### Automated Tests
- ALB health and response tests
- WordPress installation verification
- Load balancing functionality
- Database connectivity
- Auto Scaling Group health
- Target group health checks

### Manual Testing
- SSH access via bastion host
- WordPress admin interface
- Database administration
- Performance testing

## 📊 Monitoring & Observability

### Built-in Monitoring
- CloudWatch metrics for EC2 instances
- ALB target health monitoring
- RDS performance metrics
- Auto Scaling activities

### Optional Enhancements
- CloudWatch Dashboards
- Custom metrics and alarms
- Log aggregation
- Performance Insights for RDS

## 🌍 Multi-Environment Support

The project supports multiple environments with different configurations:

### Development Environment
- Minimal resources for cost optimization
- Relaxed security for development access
- Single AZ deployment (optional)

### Staging Environment
- Production-like configuration
- Testing and validation environment
- Performance testing capabilities

### Production Environment
- High availability across multiple AZs
- Enhanced security configurations
- Monitoring and alerting
- Backup and disaster recovery

## 💰 Cost Optimization

### Development Environment
- t2.micro instances (Free Tier eligible)
- Single NAT Gateway
- Minimal storage allocation
- Short backup retention

### Production Environment
- Right-sized instances based on requirements
- Reserved Instances for cost savings
- Automated scaling to optimize costs
- Longer backup retention for compliance

## 🔄 CI/CD Integration

The project structure supports CI/CD integration:

### GitHub Actions Example
```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
      - name: Deploy to staging
        run: ./scripts/deploy.sh staging apply
```

### GitLab CI Example
```yaml
stages:
  - validate
  - plan
  - deploy

validate:
  script:
    - terraform init
    - terraform validate

plan:
  script:
    - ./scripts/deploy.sh staging plan

deploy:
  script:
    - ./scripts/deploy.sh staging apply
  when: manual
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
# Using the deployment script
./scripts/deploy.sh dev destroy

# Or using Terraform directly
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

## 🔮 Future Enhancements

### Security Improvements
- [ ] SSL/TLS certificates with AWS Certificate Manager
- [ ] AWS WAF integration
- [ ] VPC Flow Logs
- [ ] AWS Secrets Manager for database credentials
- [ ] AWS Systems Manager Session Manager

### Performance & Scalability
- [ ] CloudFront CDN integration
- [ ] ElastiCache for caching
- [ ] RDS Multi-AZ deployment
- [ ] Application-level auto scaling

### Operational Excellence
- [ ] Automated backup strategies
- [ ] Blue/Green deployment pipeline
- [ ] Infrastructure drift detection
- [ ] Cost optimization recommendations

### Multi-Region Setup
- [ ] Cross-region replication
- [ ] Route 53 health checks and failover
- [ ] Global load balancing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the project structure
4. Test your changes with the testing script
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow Terraform best practices
- Use consistent naming conventions
- Add appropriate comments and documentation
- Test changes in development environment first
- Update documentation for new features

## 🆘 Troubleshooting

### Common Issues

**Issue**: Terraform initialization fails
**Solution**: Check AWS credentials and region configuration

**Issue**: Key pair not found error
**Solution**: Create the key pair in AWS or update the configuration

**Issue**: WordPress shows database connection error
**Solution**: Check RDS instance status and security group rules

**Issue**: Cannot access WordPress site
**Solution**: Verify ALB health checks and target group status

### Getting Help

1. Check the troubleshooting section
2. Review CloudWatch logs for detailed error messages
3. Use the testing script to identify issues
4. Check AWS Console for resource status
5. Open an issue in the repository

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or issues:
- Check the troubleshooting section
- Review AWS documentation
- Open an issue in this repository
- Contact the DevOps team

---

**Built with ❤️ using AWS, Terraform, and modern DevOps practices**

*This improved project demonstrates enterprise-grade cloud architecture principles and serves as a foundation for scalable, maintainable infrastructure on AWS.*
