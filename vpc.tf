resource "aws_vpc" "aws_capstone_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "AwsCapstoneVPC"
  }
}

# Create Public Subnet 1 in the VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.deham14.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.aws_availablity_zone_a
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}

# Create Public Subnet 2 in the VPC
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.deham14.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.aws_availability_zone_b
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

# Create Private Subnet 1 in the VPC
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.deham14.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.aws_availablity_zone_a
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

