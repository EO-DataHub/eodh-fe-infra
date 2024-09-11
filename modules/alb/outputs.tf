output "alb_id" {
  value = aws_lb.alb.id
}
output "alb_name" {
  value = aws_lb.alb.dns_name
}
output "listener_80" {
  value = aws_lb_listener.listener_80.arn
}

