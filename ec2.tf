# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Creating Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type_t2micro
  availability_zone      = var.aws_availablity_zone_a
  vpc_security_group_ids = [aws_security_group.aws_ssh_sg.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = "vockey"
  tags = {
    Name = "AwsCapstoneBastionHost"
  }
}


# Commenting out the Web Server Instances 
# These instances are not required, since we are using Auto Scaling Group

# # Create Web Server Instance in Public Subnet 1
# resource "aws_instance" "web" {
#   ami                    = data.aws_ami.amazon_linux_2.id
#   instance_type          = var.aws_instance_type_t2micro
#   availability_zone      = var.aws_availablity_zone_a
#   vpc_security_group_ids = [aws_security_group.aws_capstone_sg.id]
#   subnet_id              = aws_subnet.public_subnet_1.id
#   key_name               = "vockey"
#   user_data              = file("userdata.sh")
#   tags = {
#     Name = "AwsCapstoneWebServer"
#   }
# }

# Second Instance for Load Balancing testing -- Will be replaced by Auto Scaling Group
# resource "aws_instance" "web2" {
#   ami                    = data.aws_ami.amazon_linux_2.id
#   instance_type          = var.aws_instance_type_t2micro
#   availability_zone      = var.aws_availablity_zone_a
#   vpc_security_group_ids = [aws_security_group.aws_capstone_sg.id]
#   subnet_id              = aws_subnet.public_subnet_1.id
#   key_name               = "vockey"
#   user_data              = file("userdata.sh")
#   tags = {
#     Name = "AwsCapstoneWebServer2"
#   }
# }

