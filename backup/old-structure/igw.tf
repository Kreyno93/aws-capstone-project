
# Create Internet Gateway
resource "aws_internet_gateway" "aws_capstone_igw" {
  vpc_id = aws_vpc.aws_capstone_vpc.id

  tags = {
    Name = "AwsCapstoneIG"
  }
}