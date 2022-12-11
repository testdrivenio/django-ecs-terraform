resource "aws_cloudwatch_log_group" "django" {
  name              = "/ecs/${local.name}-django"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "django" {
  name           = "${local.name}-django"
  log_group_name = aws_cloudwatch_log_group.django.name
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${local.name}-nginx"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_stream" "nginx" {
  name           = "${local.name}-nginx"
  log_group_name = aws_cloudwatch_log_group.nginx.name
}
