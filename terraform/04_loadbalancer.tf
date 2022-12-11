# Production Load Balancer
resource "aws_lb" "default" {
  name               = local.name
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load-balancer.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# Target group
resource "aws_alb_target_group" "default" {
  name     = local.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }

  depends_on = [aws_lb.default]
}

# Listener (redirects traffic from the load balancer to the target group)
resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.default]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default.arn
  }
}
