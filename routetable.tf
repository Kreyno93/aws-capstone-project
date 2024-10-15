# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_capstone_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Create a Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  tags = {
    Name = "PrivateRouteTable"
  }
}
