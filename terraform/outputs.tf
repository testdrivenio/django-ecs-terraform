output "alb_hostname" {
  value = aws_lb.default.dns_name
}
