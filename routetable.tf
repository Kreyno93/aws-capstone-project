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

# Associate Public Subnet 1 with the Route Table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Public Subnet 2 with the Route Table
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnet 1 with the Route Table
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate Private Subnet 2 with the Route Table
resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

