resource "aws_autoscaling_group" "default" {
  name                 = local.name
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.default.name
  vpc_zone_identifier  = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
