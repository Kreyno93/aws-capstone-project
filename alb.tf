# Adding Application Load Balancer

resource "aws_lb" "capstone_lb" {
  name                       = "capstone-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.aws_capstone_lb_sg.id]
  subnets                    = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false

  tags = {
    Name = "CapstoneLoadBalancer"
  }
}

# Adding Target Group

resource "aws_lb_target_group" "capstone_tg" {
  name        = "capstone-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws_capstone_vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "CapstoneTargetGroup"
  }
}

# Adding Listener
resource "aws_lb_listener" "capstone_listener" {
  load_balancer_arn = aws_lb.capstone_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.capstone_tg.arn
  }
}

# # Target Group Attachment
# resource "aws_lb_target_group_attachment" "capstone_attachment" {
#   target_group_arn = aws_lb_target_group.capstone_tg.arn
#   target_id        = aws_instance.web.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "capstone_attachment2" {
#   target_group_arn = aws_lb_target_group.capstone_tg.arn
#   target_id        = aws_instance.web2.id
#   port             = 80
# }