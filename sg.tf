
# Security Group for SSH
resource "aws_security_group" "aws_ssh_sg" {
  name   = "AWS-Capstone-SSH-SG"
  vpc_id = aws_vpc.aws_capstone_vpc.id
  description = "Allow SSH access to EC2 instances"
}

resource "aws_vpc_security_group_ingress_rule" "aws_ssh_sg_rule" {
  security_group_id = aws_security_group.aws_ssh_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  description = "Allow SSH access to EC2 instances"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ssh" {
  security_group_id = aws_security_group.aws_ssh_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group for HTTP
resource "aws_security_group" "aws_webserver_sg" {
  name   = "AWS-Capstone-WebServer-SG"
  vpc_id = aws_vpc.aws_capstone_vpc.id

  tags = {
    Name              = "AwsCapstoneWebServerSG"
    SecurityGroupName = "AwsCapstoneWebServerSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "aws_webserver_sg_rule" {
  security_group_id = aws_security_group.aws_webserver_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  description = "Allow HTTP access to EC2 instances"
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_webserver" {
  security_group_id = aws_security_group.aws_webserver_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Uncomment the following block if you want to allow HTTPS access as well
# resource "aws_vpc_security_group_ingress_rule" "aws_webserver_sg_rule_https" {
#   security_group_id = aws_security_group.aws_webserver_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 443
#   ip_protocol = "tcp"
#   to_port     = 443
#   description = "Allow HTTPS access to EC2 instances"
# }

# Security Group for Load Balancer
resource "aws_security_group" "aws_capstone_lb_sg" {
  name   = "AWS-Capstone-LoadBalancer-SG"
  vpc_id = aws_vpc.aws_capstone_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "aws_capstone_lb_sg_rule" {
  security_group_id = aws_security_group.aws_capstone_lb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  description = "Allow HTTP access to Load Balancer"
}

# Uncomment the following block if you want to allow HTTPS access as well
# resource "aws_vpc_security_group_ingress_rule" "aws_capstone_lb_sg_rule_https" {
#   security_group_id = aws_security_group.aws_capstone_lb_sg.id

#   cidr_ipv4   = "0.0.0.0/0"
#   from_port   = 443
#   ip_protocol = "tcp"
#   to_port     = 443
#   description = "Allow HTTPS access to Load Balancer"
# }

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_lb" {
  security_group_id = aws_security_group.aws_capstone_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# Security Group for RDS
resource "aws_security_group" "aws_rds_sg" {
  name        = "AWS-Capstone-RDS-SG"
  description = "Allow traffic to RDS"
  vpc_id      = aws_vpc.aws_capstone_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "aws_rds_sg_rule" {
  security_group_id = aws_security_group.aws_rds_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
  description = "Allow MySQL access to RDS"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_rds" {
  security_group_id = aws_security_group.aws_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
