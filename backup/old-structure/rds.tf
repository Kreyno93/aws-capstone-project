# Create subnet group for Aurora Cluster
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = "10"
  db_name                = "wordpress"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  identifier             = "rds-db"
  username               = "wordpressuser"
  password               = "password3141!"
  skip_final_snapshot    = true
  multi_az               = false
  storage_encrypted      = false
  vpc_security_group_ids = [aws_security_group.aws_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "rds_db_wordpress"
  }
}

# Output the endpoint
output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}
