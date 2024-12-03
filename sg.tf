# Security Group for SSH
resource "aws_security_group" "aws_ssh_sg" {
  name   = "AWS-Capstone-SSH-SG"
  vpc_id = aws_vpc.aws_capstone_vpc.id

  # Allow SSH inbound traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Security Group for Load Balancer
resource "aws_security_group" "aws_capstone_lb_sg" {
  name   = "AWS-Capstone-LoadBalancer-SG"
  vpc_id = aws_vpc.aws_capstone_vpc.id

  # Allow HTTP inbound traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AwsCapstoneLoadBalancerSG"
  }
}

# Security Group for HTTP
resource "aws_security_group" "aws_webserver_sg" {
  name   = "AWS-Capstone-WebServer-SG"
  vpc_id = aws_vpc.aws_capstone_vpc.id

  # Allow HTTP inbound traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name              = "AwsCapstoneWebServerSG"
    SecurityGroupName = "AwsCapstoneWebServerSG"
  }
}

# Security Group for RDS
resource "aws_security_group" "aws_rds_sg" {
  name        = "AWS-Capstone-RDS-SG"
  description = "Allow traffic to RDS"
  vpc_id      = aws_vpc.aws_capstone_vpc.id

  # Allow MySQL inbound traffic
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}