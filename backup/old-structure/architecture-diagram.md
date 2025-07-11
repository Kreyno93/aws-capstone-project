# AWS Capstone Project Architecture Diagram

## High-Level Architecture Overview

```
                                    ┌─────────────────────────┐
                                    │        Internet         │
                                    └───────────┬─────────────┘
                                                │
                                    ┌───────────▼─────────────┐
                                    │   Internet Gateway      │
                                    │  (aws_capstone_igw)     │
                                    └───────────┬─────────────┘
                                                │
┌───────────────────────────────────────────────┼───────────────────────────────────────────────┐
│                                               │                                               │
│                        AWS VPC (10.0.0.0/16) - AwsCapstoneVPC                              │
│                                               │                                               │
│    ┌─────────────────────────────────────────┬┴─────────────────────────────────────────┐    │
│    │                                         │                                          │    │
│    │                                         │                                          │    │
│    │  ┌─────────────────────────────────────────────────────────────────────────────┐  │    │
│    │  │                Application Load Balancer (capstone-lb)                     │  │    │
│    │  │                    Spans Public Subnets 1 & 2                             │  │    │
│    │  └─────────────────────────────────────────────────────────────────────────────┘  │    │
│    │                                         │                                          │    │
│    │            us-west-2a                   │                us-west-2b               │    │
│    │                                         │                                          │    │
│    │  ┌─────────────────────────────────────┐│┌─────────────────────────────────────────┐ │    │
│    │  │        Public Subnet 1              │││        Public Subnet 2                 │ │    │
│    │  │        (10.0.1.0/24)                │││        (10.0.3.0/24)                   │ │    │
│    │  │                                     │││                                         │ │    │
│    │  │  ┌─────────────────────────────────┐│││                                         │ │    │
│    │  │  │      Bastion Host               │││                                         │ │    │
│    │  │  │      (t2.micro)                 │││                                         │ │    │
│    │  │  │   AwsCapstoneBastionHost        │││                                         │ │    │
│    │  │  └─────────────────────────────────┘│││                                         │ │    │
│    │  │                                     │││                                         │ │    │
│    │  │  ┌─────────────────────────────────┐│││                                         │ │    │
│    │  │  │      NAT Gateway                │││                                         │ │    │
│    │  │  │      + Elastic IP               │││                                         │ │    │
│    │  │  └─────────────────────────────────┘│││                                         │ │    │
│    │  └─────────────────────────────────────┘│└─────────────────────────────────────────┘ │    │
│    │                                         │                                          │    │
│    │  ┌─────────────────────────────────────┐│┌─────────────────────────────────────────┐ │    │
│    │  │       Private Subnet 1              │││       Private Subnet 2                 │ │    │
│    │  │       (10.0.2.0/24)                 │││       (10.0.4.0/24)                    │ │    │
│    │  │                                     │││                                         │ │    │
│    │  │  ┌─────────────────────────────────┐│││  ┌─────────────────────────────────┐    │ │    │
│    │  │  │   WordPress Instance            │││  │   WordPress Instance            │    │ │    │
│    │  │  │   (Auto Scaling Group)          │││  │   (Auto Scaling Group)          │    │ │    │
│    │  │  │   t2.micro                      │││  │   t2.micro                      │    │ │    │
│    │  │  └─────────────────────────────────┘│││  └─────────────────────────────────┘    │ │    │
│    │  │                                     │││                                         │ │    │
│    │  │  ┌─────────────────────────────────┐│││  ┌─────────────────────────────────┐    │ │    │
│    │  │  │      RDS MySQL                  │││  │      RDS MySQL                  │    │ │    │
│    │  │  │      (db.t3.micro)              │││  │      (Subnet Group)             │    │ │    │
│    │  │  │      wordpress DB               │││  │                                 │    │ │    │
│    │  │  └─────────────────────────────────┘│││  └─────────────────────────────────┘    │ │    │
│    │  └─────────────────────────────────────┘│└─────────────────────────────────────────┘ │    │
│    └─────────────────────────────────────────┴──────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Detailed Component Flow

### 1. Traffic Flow
```
Internet → Internet Gateway → Application Load Balancer → Target Group → WordPress Instances (Private Subnets)
```

### 2. Database Connectivity
```
WordPress Instances → RDS MySQL (Private Subnets) via Security Groups
```

### 3. Administrative Access
```
Internet → Bastion Host (Public Subnet) → SSH → WordPress Instances (Private Subnets)
```

### 4. Outbound Internet Access
```
WordPress Instances → NAT Gateway → Internet Gateway → Internet
```

## Security Group Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              Security Groups                                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐         │
│  │   SSH Security      │  │  WebServer Security │  │ LoadBalancer Security│         │
│  │   Group             │  │  Group              │  │ Group               │         │
│  │                     │  │                     │  │                     │         │
│  │ Port: 22            │  │ Port: 80            │  │ Port: 80            │         │
│  │ Source: 0.0.0.0/0   │  │ Source: 0.0.0.0/0   │  │ Source: 0.0.0.0/0   │         │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘         │
│                                                                                     │
│  ┌─────────────────────┐                                                           │
│  │   RDS Security      │                                                           │
│  │   Group             │                                                           │
│  │                     │                                                           │
│  │ Port: 3306          │                                                           │
│  │ Source: 0.0.0.0/0   │                                                           │
│  └─────────────────────┘                                                           │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Auto Scaling Configuration

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           Auto Scaling Group                                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Launch Template: wordpress-template                                                │
│  ├─ AMI: Amazon Linux 2                                                             │
│  ├─ Instance Type: t2.micro                                                         │
│  ├─ Security Groups: WebServer SG + SSH SG                                          │
│  └─ User Data: WordPress installation script                                        │
│                                                                                     │
│  Scaling Configuration:                                                             │
│  ├─ Desired Capacity: 2                                                             │
│  ├─ Min Size: 2                                                                     │
│  ├─ Max Size: 3                                                                     │
│  └─ Target Tracking: CPU Utilization @ 50%                                         │
│                                                                                     │
│  Deployment:                                                                        │
│  ├─ Subnets: Private Subnet 1 & 2                                                  │
│  ├─ Target Group: capstone-tg                                                       │
│  └─ Health Checks: ALB Target Group                                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Network Routing

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              Route Tables                                           │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────┐  ┌─────────────────────────────────────────┐   │
│  │      Public Route Table         │  │        Private Route Table             │   │
│  │                                 │  │                                         │   │
│  │  Destination: 0.0.0.0/0         │  │  Destination: 0.0.0.0/0                 │   │
│  │  Target: Internet Gateway       │  │  Target: NAT Gateway                    │   │
│  │                                 │  │                                         │   │
│  │  Associated Subnets:            │  │  Associated Subnets:                    │   │
│  │  ├─ Public Subnet 1             │  │  ├─ Private Subnet 1                   │   │
│  │  └─ Public Subnet 2             │  │  └─ Private Subnet 2                   │   │
│  └─────────────────────────────────┘  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Internet  │───▶│     IGW     │───▶│     ALB     │───▶│ Target Group│
│   Traffic   │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                │
                                                                ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    RDS      │◀───│  WordPress  │◀───│Auto Scaling │◀───│Health Checks│
│   MySQL     │    │ Instances   │    │   Group     │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                           │
                           ▼
                   ┌─────────────┐
                   │NAT Gateway  │
                   │for outbound │
                   │   traffic   │
                   └─────────────┘
```

## Key Architecture Benefits

1. **High Availability**: Multi-AZ deployment ensures service continuity
2. **Scalability**: Auto Scaling Group handles traffic variations
3. **Security**: Private subnets protect application and database layers
4. **Cost Optimization**: Right-sized instances and single NAT Gateway
5. **Fault Tolerance**: Load balancer health checks and auto-recovery
6. **Maintainability**: Infrastructure as Code with Terraform

## Resource Dependencies

```
VPC → Subnets → Security Groups → EC2 Instances
 │      │           │               │
 │      │           └─────────────────────┐
 │      │                                 │
 │      └─ Internet Gateway               │
 │      └─ NAT Gateway                    │
 │      └─ Route Tables                   │
 │                                        │
 └─ RDS Subnet Group → RDS Instance ──────┘
                                          │
    Launch Template → Auto Scaling Group ─┘
                           │
    Target Group ──────────┘
         │
    Load Balancer ─────────┘
```

This architecture provides a robust, scalable, and secure WordPress hosting solution following AWS best practices.
