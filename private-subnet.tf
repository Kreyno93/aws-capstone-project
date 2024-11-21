# Create Private Subnet 1 in the VPC
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.aws_capstone_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.aws_availability_zone_a
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet1"
  }
}

# Create Private Subnet 2 in the VPC
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.aws_capstone_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = var.aws_availability_zone_b
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet2"
  }
}